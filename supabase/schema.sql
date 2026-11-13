-- Laqait - Supabase schema (SWE 463, Group 05, Phase 3)
--
-- How to use: Supabase Dashboard -> SQL Editor -> New query -> paste this
-- whole file -> Run. It is safe to run again: every statement first checks
-- whether the object already exists.
--
-- Phase 3 creates: profiles, reports, and the report-photos Storage bucket.
-- Phase 4 will add: conversations, messages and notifications (F4, F6).

-- ---------------------------------------------------------------------------
-- 1) Profiles: one row per user, created automatically on sign-up.
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  name       text not null default '',
  email      text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Signed-in users can read profiles" on public.profiles;
create policy "Signed-in users can read profiles"
  on public.profiles for select
  to authenticated
  using (true);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Runs for every new account: allows only @kfupm.edu.sa emails and
-- creates the matching profile row with the name typed on Sign Up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if coalesce(lower(new.email), '') not like '%@kfupm.edu.sa' then
    raise exception 'Only @kfupm.edu.sa emails can sign up';
  end if;

  insert into public.profiles (id, name, email)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'name', ''), new.email);

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 2) Reports (Features F1, F2, F3, F5).
-- ---------------------------------------------------------------------------
create table if not exists public.reports (
  id          uuid primary key default gen_random_uuid(),
  type        text not null check (type in ('lost', 'found')),
  title       text not null check (char_length(title) between 1 and 80),
  description text not null default '',
  category    text not null,
  building_id text not null,
  photo_url   text,
  occurred_at timestamptz not null default now(),
  status      text not null default 'active'
              check (status in ('active', 'recovered')),
  owner_id    uuid not null default auth.uid()
              references auth.users (id) on delete cascade,
  created_at  timestamptz not null default now()
);

create index if not exists reports_occurred_at_idx
  on public.reports (occurred_at desc);

alter table public.reports enable row level security;

drop policy if exists "Signed-in users can read reports" on public.reports;
create policy "Signed-in users can read reports"
  on public.reports for select
  to authenticated
  using (true);

drop policy if exists "Users can post their own reports" on public.reports;
create policy "Users can post their own reports"
  on public.reports for insert
  to authenticated
  with check ((select auth.uid()) = owner_id);

drop policy if exists "Owners can update their reports" on public.reports;
create policy "Owners can update their reports"
  on public.reports for update
  to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

-- ---------------------------------------------------------------------------
-- 3) Storage bucket for report photos (public read, owner-only upload).
--    Each user uploads into a folder named with their user id.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('report-photos', 'report-photos', true)
on conflict (id) do nothing;

drop policy if exists "Users upload photos to their own folder" on storage.objects;
create policy "Users upload photos to their own folder"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'report-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Anyone can view report photos" on storage.objects;
create policy "Anyone can view report photos"
  on storage.objects for select
  using (bucket_id = 'report-photos');
