# india_green_app

One App. Every Farmer. Every Partner. — IGO Group agritech super-app.

## Setup

```bash
cp .env.example .env        # then fill in SUPABASE_URL and SUPABASE_ANON_KEY
flutter pub get
dart run build_runner build -d
flutter run
```

`.env` is git-ignored but bundled as an app asset, so only put values in it that
are safe to ship inside the app (the Supabase **anon** key — never a service-role
key or a private API key).

## Release signing (Android)

Create `android/key.properties` (git-ignored) with `storeFile`, `storePassword`,
`keyAlias`, `keyPassword`. Without it, release builds fall back to debug keys
and **must not** be uploaded to the Play Store.

## Backend

Supabase migrations live in `supabase/migrations`; the OTP SMS hook is
`supabase/functions/send-sms` (see its header for required secrets).
