# Android Setup Guide (Firebase + Agora)

This guide makes the project run on Android after you fill placeholder values.

## 1) Prerequisites
1. Flutter stable installed.
2. Android Studio + Android SDK.
3. Firebase project.
4. Agora project.

## 2) Install dependencies
```bash
flutter pub get
```

## 3) Configure Firebase (Android)

### 3.1 Create Firebase project
In Firebase Console:
- Create project.
- Enable Authentication providers:
  - Email/Password
  - Google
- Enable Cloud Firestore.

### 3.2 Register Android app
- Package name: `com.example.interview` (or update app id consistently if changed).
- Download `google-services.json`.

### 3.3 Replace placeholder files
Replace both files with your downloaded file:
- `android/app/src/google-services.json`
- `android/app/google-services (7).json`

## 4) Configure Agora
Open `lib/config/app_secrets.dart` and replace:
- `YOUR_AGORA_APP_ID`
- `YOUR_AGORA_TEMP_TOKEN`

Rules:
- If Agora project uses temporary token auth, set `agoraTempToken`.
- If token is disabled in Agora project, set `agoraTempToken` to empty string `''`.

## 5) Firestore structure used by app

### users/{uid}
- firstName, lastName, email, role
- isProfileComplete (bool)
- phone, location, headline, summary

### interviews/{interviewId}
- interviewerId, candidateId, candidateName
- title, position, duration
- startTime, endTime
- status (`scheduled|ongoing|completed|cancelled`)
- roomId (used as Agora channel name)

## 6) Recommended Firestore rules (starter)
```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /interviews/{interviewId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 7) Run on Android
```bash
flutter run -d android
```

## 8) Auth behavior (implemented)
- Email/password signup sends verification email.
- Login with email/password requires verified email.
- Google sign-in creates profile on first login with role from selected tab.
- Profile completion is mandatory before dashboard.

## 9) Video calling behavior (implemented)
- Interview `roomId` is Agora channel ID.
- Interviewer joins with UID 1, candidate joins with UID 2.
- Local preview + remote video render.
- Mic/camera toggle supported.

## 10) Common issues
- **`Firebase init error`**: wrong/missing `google-services.json`.
- **Remote user not visible**: users are not in same `roomId`.
- **Agora join failure**: invalid App ID/token.
- **Login fails after signup**: verify email first.
