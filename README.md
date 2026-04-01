# Skill Deck Interview Platform

Skill Deck is a Flutter app for running interview workflows with **one dependable real-time stack: Agora**.

## How this project works (high-level)

### 1) Authentication and user bootstrap
- Firebase Authentication handles sign-up/sign-in.
- On account creation, a profile document is created in Firestore under `users/{uid}`.
- On login, app loads role + profile details and routes user:
  - Candidate → Candidate Dashboard
  - Interviewer → Interviewer Dashboard
- If profile is incomplete, user is routed to Profile Form first.

### 2) Interview lifecycle
- Interviewers schedule interviews (candidate, topic, date/time, duration).
- Each interview record gets a unique `roomId` in Firestore.
- That same `roomId` is used as **Agora channelId**.
- Interview status transitions: scheduled → ongoing → completed.

### 3) Video call lifecycle (Agora only)
- `CallService` initializes Agora engine.
- App joins channel using interview `roomId`.
- Local media is published; remote participant events drive the UI.
- Mic/camera toggles are controlled from the in-call UI.

---

## Why WebRTC was removed

This project had both Agora and a second Flutter-WebRTC/Firestore signaling implementation. Maintaining both introduces:
- duplicated call logic,
- inconsistent debugging paths,
- higher failure surface in production.

To keep the app reliable and maintainable, the project now uses **only Agora** for calls.

To reduce merge conflicts with older branches, compatibility shims are kept for
`MeetingScreen` and `MeetingService`, but both forward to Agora-backed flows.

---

## Setup (step-by-step)

## 1) Install
```bash
git clone <your-repo-url>
cd TEMP
flutter pub get
```

## 2) Configure Firebase

1. Create Firebase project.
2. Enable:
   - Authentication (Email/Password, Google)
   - Cloud Firestore
3. Android:
   - download `google-services.json`
   - place at `android/app/google-services.json`
4. iOS:
   - download `GoogleService-Info.plist`
   - place at `ios/Runner/GoogleService-Info.plist`

### Suggested Firestore collections
- `users`
- `interviews`
- `recordings`

## 3) Configure Agora placeholders

Open `lib/config/app_secrets.dart` and replace:

```dart
static const String agoraAppId = 'YOUR_AGORA_APP_ID';
static const String agoraTempToken = 'YOUR_AGORA_TEMP_TOKEN';
```

### How to fill these values
1. Open Agora Console.
2. Create project.
3. Copy App ID → `agoraAppId`.
4. Token behavior:
   - App Certificate disabled: set `agoraTempToken` to empty string `''`.
   - App Certificate enabled: generate temporary token and paste into `agoraTempToken`.

> Production recommendation: generate tokens from backend, not in app code.

## 4) Run
```bash
flutter run
```

---

## Authentication hardening now included
- Role-checked login (candidate/interviewer mismatch is blocked).
- Password reset flow from Login screen.
- Improved Firebase auth error mapping.
- Login email format validation.

---

## Troubleshooting

### `Agora App ID not configured`
You still have placeholder values in `lib/config/app_secrets.dart`.

### Remote user not visible
- Both users must join exact same `roomId`.
- Camera/microphone permissions must be granted.
- Check Agora App ID/token configuration.

### Wrong dashboard after login
Role mismatch is intentionally blocked. Sign in using the correct role account.

---

## Security notes
- Keep placeholders in source control.
- Do not commit production secrets.
- Keep Firebase platform files and secret values managed per environment.
