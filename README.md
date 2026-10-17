# Laqait – KFUPM Campus Lost & Found

SWE 463 · Term 261 · Group 05

Laqait lets KFUPM students report found and lost items, browse and filter
reports by type, building and date, and chat with the finder or owner
without sharing phone numbers.

| Member | ID |
|---|---|
| Naif Alenizi | 202154090 |
| Rayn Alsaedi | 202169810 |
| Faisal Alsulami | 202175830 |
| Turki Alslamah | 202172030 |

Figma: https://www.figma.com/design/0XBLZVZvW2cGIPAJPEDb13

## Phase 2 starter app

This is the starter project. All 12 screens from the Figma design exist,
and the navigation follows the flow in Section 3 of the Phase 2 document
(Sign In → bottom navigation with Home, Search, Report, Chats and Account).
The screens run on local sample data. Supabase is connected in Phase 3.

## Setup

Requirements: Flutter 3.22 or newer (Dart 3.4+).

```bash
git clone https://github.com/TurkiAlslamah/swe463.git
cd swe463

# Generate the platform folders (android/, ios/, web/ ...) the first time.
# Existing files in lib/ are not overwritten.
flutter create . --project-name laqait --org sa.edu.kfupm

flutter pub get
flutter run
```

Sign in with any `@kfupm.edu.sa` email and any password.

To use Supabase later, pass the keys at run time (they are never committed):

```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Photo picker permissions

`image_picker` needs these entries after `flutter create`:

- **iOS** – `ios/Runner/Info.plist`: `NSPhotoLibraryUsageDescription` and
  `NSCameraUsageDescription`.
- **Android** – nothing extra for the gallery on Android 13+.

## Packages

| Package | Purpose |
|---|---|
| `supabase_flutter` | Database, storage, sign-in and realtime updates |
| `provider` | Shared state (auth, reports, chats, notifications, saved reports) |
| `go_router` | Routes and the bottom-navigation shell |
| `image_picker` | Take or choose the item photo |
| `shared_preferences` | Keep saved report IDs on the phone |
| `intl` | Date and time formatting |

## Project structure

```
lib/
├── main.dart            app entry, providers, router
├── app_router.dart      routes and bottom navigation
├── models/              data classes
├── screens/             one file per screen (12 screens)
├── widgets/             shared UI parts
├── services/            Supabase calls (sample data for now)
└── providers/           shared state
assets/
├── buildings.json       building list for the map picker
└── campus_map.png       campus map image
```

| Screen | File | Feature |
|---|---|---|
| 01 Sign In | `sign_in_screen.dart` | – |
| 02 Sign Up | `sign_up_screen.dart` | – |
| 03 Home | `home_screen.dart` | F3 |
| 04 Search | `search_screen.dart` | F3 |
| 05 New Report | `new_report_screen.dart` | F1, F2 |
| 06 Map Picker | `map_picker_screen.dart` | F7 |
| 07 Report Details | `report_details_screen.dart` | F4, F5, F7, F8 |
| 08 Saved Reports | `saved_reports_screen.dart` | F8 |
| 09 Chats | `chats_screen.dart` | F4 |
| 10 Chat | `chat_screen.dart` | F4 |
| 11 Notifications | `notifications_screen.dart` | F6 |
| 12 My Account | `account_screen.dart` | F5, F8 |

Campus map data © OpenStreetMap contributors. The bundled `campus_map.png`
is a placeholder until the exported OSM map is added.

## AI disclosure

We used AI as a assistant for this phase. It helped with:

- Gather some possible requirements
- Setting up the Flutter project structure and packages
- Writing struture of the screens, shared widgets, models, services and providers. Thats helps us to understands how the codes work
- help us to write this README and give us a phase2 templete 


