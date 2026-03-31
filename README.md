# FeastForged

FeastForged is a Flutter nutrition-tracking app focused on simple logging, clear macro targets, and a low-friction daily dashboard.

## MVP features

- Email/password authentication with Supabase
- Onboarding flow for calorie and macro targets
- Dashboard with daily calorie and macro progress
- Search from a seeded food catalog
- Meal logging by grams and meal type
- Delete logged entries

## Stack

- Flutter
- Flutter Riverpod
- GoRouter
- Supabase

## Local setup

1. Create or connect a Supabase project.
2. Apply the SQL migrations in `supabase/migrations`.
3. Run the app with your anon key:

```bash
flutter run --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Optional:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Supabase notes

- If email confirmation is enabled, signup sends the user back to sign in after they verify their email.
- Seed foods are added by `002_seed_foods.sql`.

## Android release signing

Create `android/key.properties` before shipping a release build:

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=../upload-keystore.jks
```

Without that file, release signing is intentionally left unconfigured so debug keys are not used for production builds.

## Verification

```bash
flutter analyze
flutter test
```
