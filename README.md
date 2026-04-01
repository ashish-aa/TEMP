# Skill Deck Interview Platform

Skill Deck is a Flutter app for **candidate/interviewer workflows** with:
- Firebase authentication + profile management.
- Firestore-based interview scheduling.
- Real-time interview dashboard for both roles.
- Video interview support using Agora (primary) and WebRTC room service (secondary module).

---

## What was fixed in this revision

### Core logic and reliability
- Removed hardcoded Agora App ID usage from service layer and replaced it with placeholders in `lib/config/app_secrets.dart`.
- Fixed WebRTC room answer-handling bug where remote description could fail to set due to inverted condition.
- Added room cleanup logic (delete ICE candidates + room document) when ending WebRTC meetings.
- Added password reset flow from login screen.
- Added role enforcement at login: candidate/interviewer tab now validates account role before allowing access.
- Added stronger auth error mapping for better user-facing messages.

### UI/UX improvements
- Added copy-to-clipboard action for WebRTC room ID.
- Improved user feedback for unimplemented recording backend by showing explicit message.
- Improved auth form validation (email format checks).

### Documentation
- Replaced generic README with full runbook (Firebase + Agora + placeholders + step-by-step setup).

---

## Prerequisites

1. Flutter SDK (stable)
2. Android Studio / Xcode (for platform builds)
3. Firebase project
4. Agora project

---

## 1) Clone + install

```bash
git clone <your-repo-url>
cd TEMP
flutter pub get
```

---

## 2) Configure Firebase

This app uses Firebase Auth + Cloud Firestore.

### A. Create Firebase project
1. Go to Firebase Console.
2. Create project.
3. Enable:
   - **Authentication** (Email/Password, Google)
   - **Cloud Firestore**

### B. Register Android app
1. Add Android app in Firebase.
2. Package name must match your app ID from `android/app/build.gradle.kts`.
3. Download `google-services.json`.
4. Place it at:
   - `android/app/google-services.json`

### C. Register iOS app
1. Add iOS app in Firebase.
2. Download `GoogleService-Info.plist`.
3. Place it at:
   - `ios/Runner/GoogleService-Info.plist`

### D. Firestore initial collections
The app expects:
- `users`
- `interviews`
- `rooms` (for WebRTC meeting module)
- `recordings` (metadata only)

### E. Suggested Firestore rules (starter)
Use stricter rules for production.

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /interviews/{interviewId} {
      allow read, write: if request.auth != null;
    }

    match /rooms/{roomId} {
      allow read, write: if request.auth != null;
      match /{sub=**} {
        allow read, write: if request.auth != null;
      }
    }

    match /recordings/{recordingId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 3) Configure Agora

Open `lib/config/app_secrets.dart` and replace placeholders:

```dart
static const String agoraAppId = 'YOUR_AGORA_APP_ID';
static const String agoraTempToken = 'YOUR_AGORA_TEMP_TOKEN';
```

### How to fill placeholders
1. Go to Agora Console.
2. Create project.
3. Copy **App ID** → put into `agoraAppId`.
4. Token behavior:
   - If your Agora project has **App Certificate disabled**, keep token empty string (`''`) and app can join without token.
   - If certificate is enabled, generate a temporary token in Agora console and set `agoraTempToken`.

> For production, generate channel tokens from a secure backend instead of hardcoding tokens.

---

## 4) Run app

```bash
flutter run
```

---

## 5) Auth flow expectations

1. User signs up as Candidate or Interviewer.
2. User logs in and role is validated against selected role tab.
3. If profile is incomplete, app routes to Profile Form.
4. After completion:
   - Interviewer → Interviewer Dashboard
   - Candidate → Candidate Dashboard

---

## 6) Video interview flow

### Agora flow (primary in dashboard)
- Interview is scheduled with `roomId` (used as Agora channel ID).
- Interviewer starts interview from dashboard.
- Candidate joins same `roomId`.
- Mic/camera toggles are supported.

### WebRTC flow (meeting module)
- Creates room in Firestore under `rooms/{roomId}`.
- Supports room join by ID.
- Cleans up room and ICE candidates on hangup.

---

## 7) Known production hardening tasks

- Move Agora token generation to backend.
- Add Firebase App Check.
- Add stricter role-based Firestore rules.
- Add end-to-end tests for auth + scheduling + call join.
- Replace demo recording toggle with actual recording backend integration.

---

## 8) Troubleshooting

### `Firebase init error`
- Ensure platform config files are present and valid.

### Video shows local only / remote missing
- Verify both users are in same `roomId`.
- Ensure camera + microphone permissions are granted.
- Verify Agora App ID and token settings.

### Role mismatch after login
- User selected wrong role tab for existing account role.

---

## Security note

Never commit real production secrets. Keep placeholders in source and inject real values securely per environment.
