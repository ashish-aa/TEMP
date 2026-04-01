---
description: Proper Flutter connectivity handling using connectivity_plus and internet_connection_checker
---

# Workflow: Implement Proper Connectivity Detection in a Flutter App

1. **Add Dependencies**
   - Open `pubspec.yaml`.
   - Under `dependencies:` add:
     ```yaml
     connectivity_plus: ^5.0.2
     internet_connection_checker: ^1.0.0+1
     ```
   - Run `flutter pub get` to fetch packages.
   // turbo

2. **Create a Connectivity Service**
   - In `lib/services/`, create `connectivity_service.dart` with a singleton class that:
     - Exposes a `Stream<ConnectivityResult>` from `Connectivity().onConnectivityChanged`.
     - Provides a method `Future<bool> hasInternet()` using `InternetConnectionChecker().hasConnection`.
   // turbo

3. **Initialize Service in Main**
   - In `main.dart`, ensure `WidgetsFlutterBinding.ensureInitialized();` before `runApp`.
   - Optionally, wrap the app with a `Provider` (e.g., `ChangeNotifierProvider`) that holds connectivity state.
   // turbo

4. **Create a Connectivity Listener Widget**
   - Create `lib/widgets/connectivity_banner.dart` that:
     - Listens to the service's stream via `StreamBuilder`.
     - Shows a banner (e.g., `MaterialBanner` or `SnackBar`) when offline.
     - Optionally, retries when back online.
   // turbo

5. **Integrate Banner into UI**
   - In your top-level scaffold (e.g., `HomePage`), include `ConnectivityBanner()` at the top of the widget tree.
   // turbo

6. **Handle Edge Cases**
   - On app start, check initial connectivity using `await Connectivity().checkConnectivity()` and `hasInternet()`.
   - Debounce rapid connectivity changes to avoid UI flicker (use `RxDart` `debounceTime` or simple `Timer`).
   // turbo

7. **Testing**
   - Write unit tests for `ConnectivityService` mocking `Connectivity` and `InternetConnectionChecker`.
   - Write widget tests to verify banner appears/disappears based on simulated stream events.
   // turbo

8. **Optional Enhancements**
   - Add retry button that re-checks internet.
   - Persist last known connectivity state using `shared_preferences`.
   - Support platform-specific permissions (Android: add `ACCESS_NETWORK_STATE` in `AndroidManifest.xml`).

**Notes**:
- `connectivity_plus` only reports network type; combine with `internet_connection_checker` to confirm actual internet access.
- Remember to cancel any `StreamSubscription` in `dispose()` if you manually subscribe.
- For a premium UI, style the banner with gradient background, smooth slide-in animation, and use Google Font (e.g., `Inter`).
