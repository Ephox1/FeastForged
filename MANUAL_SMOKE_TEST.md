# FeastForged Manual Smoke Test

Use this checklist against an MVP-compatible Supabase project with the local
`user_profiles`, `food_items`, and `meal_log_entries` tables applied.

## Preconditions

- App launches with valid `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- Seed foods from `002_seed_foods.sql` are present
- Email confirmation behavior is known for the target Supabase environment

## Core flow

1. Open the app and confirm the login screen loads without config errors.
2. Create a new account or sign in with an existing one.
3. If email confirmation is enabled:
   - confirm the app shows guidance after signup
   - verify the user can return and sign in after confirmation
4. Complete onboarding with valid stats.
5. Confirm the dashboard loads:
   - calorie ring renders
   - macro targets appear
   - empty-state CTA is visible for a new account
6. Tap `Log breakfast` or `Log food`.
7. In search:
   - confirm popular foods appear before typing
   - search for a seeded food
   - confirm results appear without obvious lag
8. Open a food and log it:
   - use a serving shortcut chip
   - verify the nutrition preview updates
   - save to a meal
9. Return to the dashboard and confirm:
   - totals update
   - the meal section shows the new entry
10. Delete the entry and confirm totals refresh.
11. Create a custom food and log it.
12. Open `Edit targets`, change a goal, and confirm the dashboard updates.
13. Use `Forgot password?` and confirm the reset flow succeeds.
14. Sign out and confirm the auth redirect returns to login.

## Pass criteria

- No crashes
- No broken navigation
- Dashboard totals match the logged meal data
- Custom foods can be created and logged
- Email-confirmation and password-reset UX are understandable
