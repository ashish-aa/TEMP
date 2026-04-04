# Skill Deck (Android-first)

Skill Deck is a Flutter interview app with:
- Firebase Auth + Firestore-backed user/interview data.
- Role-based candidate/interviewer dashboards.
- ZEGOCLOUD real-time video meetings.

> This repository is now configured with **placeholders** for secrets. Follow `docs/ANDROID_SETUP.md` to run it.

## Quick start

```bash
flutter pub get
flutter run -d android
```

Before running, fill these placeholders:
- `android/app/src/google-services.json`
- `android/app/google-services (7).json`
- `lib/config/app_secrets.dart`

See full setup guide: `docs/ANDROID_SETUP.md`.
