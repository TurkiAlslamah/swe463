-- Laqait - optional demo data for Supabase (run AFTER schema.sql).
--
-- 1. In the app, sign up two accounts:
--      demo@kfupm.edu.sa  (owns the sample reports below)
--      test@kfupm.edu.sa  (the account the instructor signs in with)
-- 2. Supabase Dashboard -> SQL Editor -> paste this file -> Run.
--
-- The instructor then sees other people's reports (can save / message them)
-- and can post their own reports (owner view: Mark as recovered).

insert into public.reports
  (type, title, description, category, building_id, occurred_at, owner_id)
select v.type, v.title, v.description, v.category, v.building_id,
       now() - v.ago, u.id
from auth.users u
cross join (values
  ('found', 'Black AirPods case',     'Found on a desk in room 120.',      'Electronics', '22',      interval '2 hours'),
  ('found', 'Student ID card',        'Left at the front desk.',           'Cards & IDs', 'library', interval '1 day'),
  ('found', 'Car keys with blue tag', 'Found near the parking gate.',      'Keys',        '59',      interval '2 days'),
  ('found', 'Black wallet',           'Found in the prayer room.',         'Wallets',     '4',       interval '4 days'),
  ('found', 'Casio calculator',       'Found after the exam in room 101.', 'Electronics', '6',       interval '3 hours'),
  ('lost',  'House keys',             'Three keys on a red ring.',         'Keys',        '22',      interval '5 days'),
  ('lost',  'Blue water bottle',      'Lost in the cafeteria.',            'Bottles',     '24',      interval '1 day')
) as v(type, title, description, category, building_id, ago)
where u.email = 'demo@kfupm.edu.sa';
