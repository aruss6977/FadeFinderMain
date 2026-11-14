# FadeFinder

**Team Members:** Alex N, Alexander R, Ronnie  
**Course:** Mobile Computing Seminar  

FadeFinder is a cross-platform mobile application built with Flutter and Firebase that helps amateur martial artists and boxers find sparring partners in their exact weight division, filter opponents by fighting style, coordinate match logistics, and vote on confirmed community bouts.

---

## Prerequisites & Required Packages
* **Flutter SDK** (Dart 3.x compatible) & a target platform (Google Chrome, Android Emulator, or iOS Simulator)
* **External Packages** (managed via `pubspec.yaml` and installed automatically with `flutter pub get`):
  * `firebase_core` — Initializes the Firebase SDK and links the app to `firebase_options.dart`.
  * `firebase_auth` — Handles user registration, email/username sign-in, password updates, and session state.
  * `cloud_firestore` — Connects the app to our NoSQL cloud database for fighter profiles, weight-class scoping, and swipe history.
  * `flutter_test` (dev dependency) — Runs our automated unit and widget test suite.

---

## How to Run the Application

1. **Clone the repository:**
   ```bash
   git clone <YOUR_GITHUB_REPO_URL>
   cd FadeFinderMain
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Launch the app (Web / Chrome or connected device):**
   ```bash
   flutter run -d chrome
   ```
4. **Run the automated test suite (15 passing tests):**
   ```bash
   flutter test
   ```

---

## Database Setup & Architecture
FadeFinder uses **Firebase Authentication** and **Cloud Firestore** (configured via `lib/firebase_options.dart`, which is already included in the repository so no manual API key setup is required to run the project).

* **`users` Collection (Cloud Firestore):**
  * Stores each fighter's `uid`, display name, age, bio, height, fighting style (`Boxing`, `Muay Thai`, `BJJ`, `MMA`, `Wrestling`), weight (`weightLbs`), calculated division (`weightClass`), and `swipedIds` array.
  * Discovery queries filter directly against `weightClass` and exclude previously swiped user IDs.

---

## Current Project Status

### What Is Working
* **Authentication & Onboarding:** Account creation with email/password validation, sign-in flow, password changes, and sign-out session clearing.
* **Weight-Class & Style Discovery:** Fetches unswiped fighters in the signed-in user's exact weight division from Firestore, supports instant client-side style filtering (`All styles`, `Boxing`, `Muay Thai`, `BJJ`, `MMA`, `Wrestling`), card swiping/challenging, and undoing the last swipe.
* **Fighter Profile & Live Division Re-Sorting:** Displays user stats and active challenges (with option to withdraw), and allows editing fighter details—automatically recalculating the user's weight division in Firestore and refreshing the Discovery deck.
* **Automated Testing:** 15/15 unit and widget tests passing across `discovery_test.dart`, `edit_profile_test.dart`, and `widget_test.dart`.

### What Is Not Working / Current MVP Limitations
* **Cross-Session Chat Persistence:** The **Chats** tab and conversation screen work interactively within a session (sending messages and confirming bouts), but chat threads and message histories are currently stored in reactive in-memory state (`ValueNotifier`) rather than persisted to a Firestore `chats` collection across restarts.
* **Cross-Session Arena Voting Persistence:** The **Vote** tab displays confirmed bouts and updates live vote tallies during a session, but vote counts are held in in-memory state and reset when the app restarts rather than persisting to Firestore.
* **Push Notifications & Photo Uploads:** Profile avatars use generated initials/icons rather than Firebase Cloud Storage image uploads, and push notifications are not yet implemented.