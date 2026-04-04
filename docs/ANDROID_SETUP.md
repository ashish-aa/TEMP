# Android Setup Guide (Firebase + ZEGOCLOUD)

This guide makes the project run on Android after you fill placeholder values.

## 1) Prerequisites
1. Flutter stable installed.
2. Android Studio + Android SDK.
3. Firebase project.
4. ZEGOCLOUD project.

## 2) Install dependencies

The project uses `zego_uikit_prebuilt_call: ^4.16.17` for dependency compatibility.

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

## 4) Configure ZEGOCLOUD
Open `lib/config/app_secrets.dart` and replace:
- `zegoAppId (integer)`
- `zegoAppSign`

Rules:
- Set these from your ZEGOCLOUD Console project:
- `zegoAppId`: numeric App ID
- `zegoAppSign`: App Sign string

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
- roomId (used as ZEGOCLOUD callID)

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

## 9) Video calling behavior (implemented with ZEGOCLOUD)
- Interview `roomId` is the ZEGOCLOUD callID.
- Interviewer and candidate join with role-prefixed user IDs based on Firebase UID.
- Room `roomId` maps to a 1:1 ZEGOCLOUD call session.
- Camera and microphone are enabled by default and controllable in-call.

## 10) Common issues
- **`Firebase init error`**: wrong/missing `google-services.json`.
- **Remote user not visible**: users are not in same `roomId`.
- **ZEGOCLOUD join failure**: invalid App ID/App Sign.
- **Login fails after signup**: verify email first.


## 11) Dependency conflict fix
If you see dependency solver errors around `connectivity_plus` or `permission_handler`, ensure your `pubspec.yaml` keeps:
- `zego_uikit_prebuilt_call: ^4.16.17`
- `connectivity_plus: ^5.0.2`
- `permission_handler: ^11.3.1`
