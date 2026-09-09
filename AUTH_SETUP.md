# SSO setup (Google · Apple · Facebook)

The Flutter side is fully wired. What's left is external accounts + native
config. Nothing below runs end-to-end until the **bold** items are done.

## Status

- [x] Firebase project `anapp-1342a` — `flutterfire configure` done
      (`lib/firebase_options.dart`, `ios/Runner/GoogleService-Info.plist`,
      `android/app/google-services.json`, google-services gradle plugin)
- [x] Google — iOS client ID + reversed-client URL scheme in `Info.plist`
- [ ] Google — enable the provider in Firebase console → Auth → Sign-in method
- [ ] Google — Web OAuth client ID for `AN_GOOGLE_SERVER_CLIENT_ID`
      (needed for Android + backend token verification)
- [ ] Apple — see §3
- [ ] Facebook — see §4 (Info.plist / strings.xml still have `TODO_` values)
- [ ] Backend — `AuthApi` points at a placeholder URL

Architecture: each provider → **Firebase Auth** → normalised `AuthUser`
(`lib/services/auth_user.dart`) with the user's **email** + a Firebase ID
token. After sign-in the token is POSTed to the backend
(`lib/services/auth_api.dart`, `POST {AN_API_BASE_URL}/v1/auth/session`);
until a real backend exists (`AppConfig.hasBackend`) that call is skipped.
Email/name are cached locally (`shared_preferences`) and shown on Profile.

---

## 1. Firebase project  **(required — unblocks everything)**

1. Create a project at <https://console.firebase.google.com>.
2. `dart pub global activate flutterfire_cli`
3. From the repo root: `flutterfire configure`
   - select the project, tick **iOS** and **Android**
   - this writes `ios/Runner/GoogleService-Info.plist`,
     `android/app/google-services.json`, and `lib/firebase_options.dart`
4. If it generates `lib/firebase_options.dart`, change `main.dart` to
   `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
5. Firebase console → **Authentication → Sign-in method** → enable
   **Google**, **Apple**, **Facebook**.

### Android extra (Firebase)
- `android/settings.gradle.kts` plugins block, add:
  `id("com.google.gms.google-services") version "4.4.2" apply false`
- `android/app/build.gradle.kts` plugins block, add:
  `id("com.google.gms.google-services")`
- `minSdk` must be ≥ 23 (Firebase Auth). Set in `android/app/build.gradle.kts`.

### iOS extra (Firebase)
- `ios/Runner/Info.plist` iOS deployment target: Firebase needs **iOS 13+**
  (`sign_in_with_apple` too). Bump in Xcode → Runner target → Minimum
  Deployments, and `IPHONEOS_DEPLOYMENT_TARGET` in `project.pbxproj`.

---

## 2. Google

- The Firebase iOS app auto-creates an OAuth client. Open
  `GoogleService-Info.plist` and copy:
  - `CLIENT_ID`  → `ios/Runner/Info.plist` `GIDClientID`
  - `REVERSED_CLIENT_ID` → `ios/Runner/Info.plist` the
    `com.googleusercontent.apps.TODO_...` URL scheme
- Create a **Web application** OAuth client in the Google Cloud console
  (same project) → pass its ID at build time:
  `--dart-define=AN_GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com`
  (required on Android; lets the backend verify the token).
- Android: add your debug + release SHA-1/SHA-256 to the Firebase Android
  app (`./gradlew signingReport`).

## 3. Apple  **(needs paid Apple Developer account)**

- <https://developer.apple.com> → Identifiers → your App ID (`com.an.an`)
  → enable **Sign in with Apple**.
- Xcode → **Runner target → Signing & Capabilities → + Sign in with
  Apple**. That wires `ios/Runner/Runner.entitlements` (already in the repo)
  into the build.
- Firebase console → Auth → Apple: fill **Services ID**, **Apple Team ID**,
  **Key ID** + the `.p8` private key (needed for token revocation / web).
- Works on a real device and on the simulator when the Mac is signed into
  an Apple ID.

## 4. Facebook

- <https://developers.facebook.com> → create an app (type: Consumer) →
  add **Facebook Login**.
- Copy **App ID** and **Client Token** (Settings → Advanced) into:
  - `ios/Runner/Info.plist`: `FacebookAppID`, `FacebookClientToken`, and
    the `fbTODO_FACEBOOK_APP_ID` URL scheme → `fb<APP_ID>`
  - `android/app/src/main/res/values/strings.xml`: `facebook_app_id`,
    `facebook_client_token`, `fb_login_protocol_scheme` (`fb<APP_ID>`)
- Facebook app → Settings → Basic → add platforms:
  - iOS bundle ID `com.an.an`
  - Android package `com.an.an` + key hash (`keytool ... | openssl sha1 -binary | openssl base64`)
- Firebase console → Auth → Facebook: paste App ID + App Secret.
- The app requests the `email` permission; Facebook may still return no
  email (account without one, or user declined) — the code handles `null`.

---

## 5. Build with the defines

```
flutter run \
  --dart-define=AN_API_BASE_URL=https://api.yourbackend.com \
  --dart-define=AN_GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com \
  --dart-define=AN_GOOGLE_IOS_CLIENT_ID=yyyy.apps.googleusercontent.com
```

Consider a `--dart-define-from-file=env.json` (git-ignored) instead.

## 6. Backend contract (when you build it)

`POST /v1/auth/session`
- `Authorization: Bearer <firebase_id_token>`
- body: `{ provider, email, name, firebase_uid }`
- verify the token with the Firebase Admin SDK, upsert the user, return
  your own session. Then tighten `AuthApi.syncSession` to throw on non-2xx
  and surface the result.
