# FeastForged Launch Checklist

## Product

- [ ] Confirm the signup flow that matches Supabase auth settings
- [x] Add profile editing after onboarding
- [x] Add custom foods for anything missing from the seed catalog
- [x] Add empty, offline, and retry states across auth, dashboard, and search
- [ ] Decide whether calorie targets should ask for sex or allow manual override
- [x] Add onboarding target explanation and dashboard empty-state guidance
- [x] Add popular foods, recent foods, and serving shortcuts

## Backend and data

- [ ] Apply both Supabase migrations in production
- [ ] Verify RLS with a second test user
- [ ] Confirm email templates and redirect URLs in Supabase auth
- [ ] Add monitoring for auth and database failures
- [ ] Backfill a larger starter food catalog or external nutrition source

## Mobile release

- [ ] Create Android keystore and `android/key.properties`
- [ ] Configure iOS signing and provisioning
- [ ] Replace default launcher icons and splash assets
- [ ] Finalize app name, bundle identifiers, and version numbers
- [ ] Test physical-device builds on Android and iPhone

## Quality

- [ ] Add unit tests for auth flow decisions
- [ ] Add widget tests for onboarding and error states
- [x] Add a smoke test for meal search to meal log to dashboard refresh
- [ ] Run `flutter analyze` and `flutter test` in CI
- [ ] Capture crash reporting before beta rollout
- [x] Keep `flutter analyze` and `flutter test` green locally

## Store readiness

- [ ] Write privacy policy and support contact
- [ ] Prepare App Store / Play Store screenshots
- [ ] Draft store descriptions and keywords
- [ ] Decide analytics and consent messaging
- [ ] Recruit a small beta group and collect first-session feedback
