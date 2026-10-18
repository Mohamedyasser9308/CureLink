# CureLink

CureLink is a Flutter mobile app for managing a patient's medication routine. It combines account and profile onboarding with medication records, dose scheduling, reminder notifications, a calendar, and profile settings. The app uses Firebase for authentication and user data, and allows caregivers to connect with patients to help manage their medication schedules, receive relevant notifications, and monitor adherence to prescribed routines.

## Current functionality

- Email and password sign-up, sign-in, and password reset, with account records stored in Cloud Firestore.
- Onboarding collects a user's name, age group, and role; the session flow checks whether the profile is complete.
- Patient home and medication management, including medication details and image selection.
- Medication dose schedules and a calendar backed by per-user Firestore data.
- Profile editing and persistent language and theme preferences.
- English and Arabic localization, light and dark themes.

The app shell also includes Notifications, but that tab currently shows an empty-state placeholder. The Emergency/SOS route is likewise a placeholder; no emergency dispatch behavior is implemented. Caregiver-specific home behavior is not implemented. Profile image upload is implemented through Cloudinary, while its account settings are currently source-configured. Treat these as app capabilities that require working backend and service configuration, not as standalone offline features.

## Technology

- Dart and Flutter (Dart SDK constraint `^3.9.0`)
- `flutter_bloc` for state management
- Firebase Core, Authentication, Cloud Firestore, Storage, and Cloud Functions packages
- `shared_preferences` for local settings
- Cloudinary HTTP image upload, `image_picker`, and `table_calendar`

The presence of Firebase Storage and Cloud Functions dependencies does not by itself imply that every feature uses them. Firebase is initialized from the platform options in `lib/firebase_options.dart`; project metadata is also present in `firebase.json`.

## Structure

```text
lib/
├── main.dart                 # Firebase, localization, settings, app startup
├── core/                     # Routing, session, shared UI, themes, settings, services
├── features/                 # Auth, onboarding, profile, home, medication, schedule, calendar, etc.
└── l10n/                     # English and Arabic localization resources
assets/                       # App imagery
android/, ios/, web/, ...     # Flutter platform projects
test/                        # Widget test source
```

Feature code generally separates data models/repositories/services from presentation pages and Cubit state management. `MainShell` hosts the patient app's bottom navigation; `SessionGate` and the splash flow route authenticated users according to their Firestore profile state.

## Main flow

1. `main()` initializes Firebase and date formatting, then loads saved theme and language preferences.
2. The splash screen routes a signed-out user to onboarding. Sign-up and sign-in use Firebase Authentication; sign-up also creates a `users/{uid}` Firestore document.
3. The profile completion flow records role, age group, and other profile data. Returning sessions are checked before entering the main shell.
4. The shell provides Home, Schedule, Calendar, Notifications, and Profile tabs. Medication and dose records are read and written under the signed-in user's Firestore document.

## Setup

### Prerequisites

Install the Flutter SDK compatible with the Dart `^3.9.0` constraint and configure the target platform's Flutter toolchain (Android Studio/Android SDK, Xcode for iOS, or the relevant desktop toolchain).

### Firebase and service configuration

The repository includes Firebase platform options and Firebase project metadata. Before running the app, ensure the Firebase project is active and has the required Authentication and Cloud Firestore services configured for the platforms you intend to use. Platform-specific Firebase configuration may also be needed by the native project/tooling. Review the image upload configuration in the profile and Cloudinary services and configure it for your own account before relying on image uploads. Do not commit private credentials.

### Run locally

From the repository root:

```sh
flutter pub get
flutter run
```

To target a connected device or emulator explicitly, add Flutter's `-d <device-id>` option.

## Build and checks

Standard Flutter commands for this project include:

```sh
flutter analyze
flutter test
flutter build apk
```

Use the appropriate `flutter build` target for iOS, web, or desktop. Platform-specific signing and release configuration are outside this README. The repository contains a widget test source, but these commands have not been run as part of documenting the project.

## Configuration notes

- Supported app locales are English (`en`) and Arabic (`ar`), with translations under `lib/l10n/` and generated localization code alongside them.
- Theme and language choices are stored locally through `shared_preferences`.
- Firebase initialization uses `DefaultFirebaseOptions.currentPlatform` from `lib/firebase_options.dart`.
- Profile image upload depends on Cloudinary settings in the app source; set up the intended account and review the upload preset and security approach before distributing builds.
