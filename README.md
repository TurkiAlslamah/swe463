# Laqait – KFUPM Campus Lost & Found

SWE 463 · Term 261 · Group 05 · Phase 3 (working prototype, tag `phase-3`)

Laqait lets KFUPM students report found and lost items, browse and filter
reports by type, building and date, save reports, and mark their own
reports as recovered. Chat and smart-match alerts come in Phase 4.

| Member | ID |
|---|---|
| Naif Alenizi | 202154090 |
| Rayan Alsaedi | 202169810 |
| Faisal Alsulami | 202175830 |
| Turki Alslamah | 202172030 |

Figma: https://www.figma.com/design/0XBLZVZvW2cGIPAJPEDb13

## Run the app

Requirements: Flutter 3.22 or newer (Dart 3.4+).

```bash
git clone https://github.com/TurkiAlslamah/swe463.git
cd swe463
flutter pub get
```

The app has two modes. Both start from a clean checkout.

### 1. Supabase mode (real data)

Create `env.json` in the project folder (it is git-ignored, never commit it).
The values are in the Phase 3 report (section 9) or in your Supabase
project under **Project Settings → API Keys**. `env.example.json` shows the
format:

```json
{
  "SUPABASE_URL": "https://YOUR-PROJECT-ID.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "YOUR-PUBLISHABLE-OR-ANON-KEY"
}
```

```bash
flutter run --dart-define-from-file=env.json
```

Sign in with the test account from the report, or create an account with
any `@kfupm.edu.sa` email.

### 2. Local demo mode (no keys)

```bash
flutter run
```

Without keys the app uses a temporary in-memory store with sample reports.
Any `@kfupm.edu.sa` email and any password signs in.

### Tests

```bash
flutter analyze
flutter test
```

## Supabase setup (once, by the team)

1. Create a free project at https://supabase.com.
2. **SQL Editor** → run `supabase/schema.sql` (tables, row-level security,
   the `report-photos` bucket and the KFUPM-email check).
3. **Authentication → Sign In / Providers → Email** → turn **off**
   "Confirm email" so new accounts can sign in at once.
4. Sign up `demo@kfupm.edu.sa` and `test@kfupm.edu.sa` in the app, then run
   `supabase/seed.sql` for sample reports.

## Phase 3 features

| # | Feature | Status |
|---|---|---|
| F1 | Report a found item (photo, item, category, building, date and time) | Implemented |
| F2 | Report a lost item | Implemented |
| F3 | Browse (Home tabs) and filter (Search by text, category, building, date) | Implemented |
| F5 | Report status: owner marks a report as Recovered | Implemented |
| F8 | Save reports (kept on the phone with shared_preferences) | Implemented |
| F7 | Campus map pin (Map Picker + pin on Report Details) | In progress – placeholder map image, real OSM export in Phase 4 |
| F4 | In-app chat | In progress – screens work on temporary sample data; Supabase Realtime in Phase 4 |
| F6 | Smart match notifications | Not started – screen exists; database trigger in Phase 4 |

**Completion: 5 of 8 essential features implemented (62.5%).**

Main end-to-end flow: **New Report** → fill the form (validated) → **Post
report** → photo uploaded to Supabase Storage and row saved in `reports` →
"Report posted" → **View report** → the new report also appears on Home,
Search and My Account.

## Packages

| Package | Purpose |
|---|---|
| `supabase_flutter` | Auth, Postgres database and Storage for photos |
| `provider` | Shared state (auth, reports, chats, notifications, saved reports) |
| `go_router` | Routes, redirects after sign-in/out, bottom-navigation shell |
| `image_picker` | Choose the item photo |
| `shared_preferences` | Keep saved report IDs on the phone |
| `intl` | Date and time formatting |

All packages are from pub.dev (BSD-3-Clause or MIT licenses).

## Data source

- **Supabase** (`lib/services/report_service.dart`, `auth_service.dart`):
  Auth for KFUPM email sign-in, the `reports` table, and the
  `report-photos` Storage bucket. Schema: `supabase/schema.sql`.
- **Temporary local store** (`lib/services/local_report_store.dart`): used
  only when no keys are given. Only `ReportService` uses it, so it can be
  removed in Phase 4 without touching any screen.
- **shared_preferences**: saved report IDs (F8).
- **App asset** `assets/buildings.json`: campus buildings and their map positions.

## Project structure

```
lib/
├── main.dart            app entry, providers, reload on sign-in
├── app_router.dart      routes and bottom navigation
├── models/              Report, Building, AppUser, ...
├── screens/             one file per screen (12 screens)
├── widgets/             ReportCard, ReportPhoto, ReportListSkeleton, ...
├── services/            Supabase, auth, reports, buildings, local store
├── providers/           shared state (Provider)
└── utils/               form validators
supabase/
├── schema.sql           tables, policies, storage bucket
└── seed.sql             optional demo reports
test/                    unit and widget tests
```

## Known issues

- Chat (F4) and notifications (F6) still use sample data in local mode;
  in Supabase mode the notification list is empty until Phase 4.
- `campus_map.png` is a placeholder image; building pins use approximate
  positions from `buildings.json`.
- Photos are chosen from the gallery only (no camera option yet).

Campus map data © OpenStreetMap contributors.

## AI disclosure

We used an AI assistant (Claude) in Phase 2 and Phase 3. It helped us to:

- plan how to split the Phase 3 work between the four members,
- draft parts of the code (Supabase services, providers, screen states and
  tests), which each member reviewed, ran, and can explain,
- write this README.

Every member tested their own part with `flutter analyze` and `flutter test`
before committing it.
