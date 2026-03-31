# FeastForged Project Alignment

## Source documents reviewed

- `H:\My Drive\PhoxdenVault\Phoxden Labs\FeastForge\ARCHITECTURE.md`
- `H:\My Drive\PhoxdenVault\Phoxden Labs\FeastForge\CLAUDE_HANDOFF.md`
- `H:\My Drive\PhoxdenVault\Phoxden Labs\FeastForge\Claude Code Session - March 31 2026.md`
- `H:\My Drive\PhoxdenVault\Phoxden Labs\FeastForge\AGENTS (I purchased feastforge through hostinger).md`
- `H:\My Drive\PhoxdenVault\Phoxden Labs\FeastForge\Supabase.md`

## What the vault docs describe

The vault docs describe a much larger product than the current repo:

- Weekly meal calendar planner
- Recipe CRUD and recipe detail flows
- Container portion calculator
- AI Chef
- AI Recipe Grab
- Community recipe marketplace
- Shopping list generation
- Household members
- RevenueCat subscriptions
- Push notifications
- Landing page and store assets

The architecture docs also use the product name `PrepPal` in several places, while the current app and domain references use `FeastForged` / `feastforge.app`.

## What the current Flutter repo actually is

The current repo at `C:\Users\nevin\ClaudeCode\feastforged` is a smaller MVP nutrition tracker:

- Email/password auth
- Onboarding for macro targets
- Daily dashboard
- Seeded food search
- Meal logging
- Delete log entries

It currently has 23 Dart source files under `lib/` and a small Supabase schema focused on:

- `user_profiles`
- `food_items`
- `meal_log_entries`

## Main mismatch

The repo is not yet the app described in the architecture docs.

Right now it is best understood as:

- `Phase 0`: a narrow meal logging MVP

The vault architecture expects:

- `Phase 1`: recipe-centric meal prep platform
- `Phase 2`: weekly planning and container math
- `Phase 3`: AI features
- `Phase 4`: community and growth loops

## Naming mismatch to resolve

There are three names in the materials:

- `PrepPal` in architecture and AI guide docs
- `FeastForge` / `FeastForged` in more recent handoff notes
- `feastforge.app` in domain notes

Before expanding the app, lock one product name and use it consistently across:

- App name
- Bundle IDs
- Landing page
- Supabase project metadata
- Store listings
- Documentation

## Supabase status

The Codex MCP server is configured locally, but MCP access is still blocked by authentication. Until the user completes `codex mcp login supabase`, live schema inspection through MCP will fail with `Auth required`.

## Recommended next build order

### 1. Finish infrastructure verification

- Complete Supabase MCP login in Codex
- Verify the current database schema against the Flutter repo migrations
- Confirm whether the app should keep the small MVP schema or move toward the larger architecture schema

### 2. Pick the actual product scope for this repo

Choose one of these paths:

- Keep this repo as the lightweight meal logging MVP and launch it faster
- Expand this repo into the full recipe + planner + AI + community product from the vault docs

### 3. If expanding, build the next missing foundation first

The next highest-value foundation is:

- Recipe model
- Recipe CRUD screens
- Container macro calculator utilities and tests

That work should happen before:

- AI Chef
- URL import
- Community marketplace
- Shopping list generation

### 4. Defer premium/platform integrations until the core loop exists

Wait on these until recipes and weekly planning are working:

- RevenueCat
- Push notifications
- Deep links
- Creator marketplace features

## Concrete backlog I would tackle next

1. Add `Recipe` domain model and `recipes` table migration
2. Add recipe create/edit/list/detail screens
3. Add container calculator utility and unit tests
4. Add weekly planner schema and planner UI shell
5. Rework the dashboard so it reflects planned meals, not only logged foods
6. Only after that, wire AI Chef and Recipe Grab through Supabase Edge Functions

## Current recommendation

Do not jump straight into AI or community features yet.

The most sensible next implementation step is:

- build recipe management + container math

That is the bridge between the current repo and the product described in the vault docs.
