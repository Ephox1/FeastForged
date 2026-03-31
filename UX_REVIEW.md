# FeastForged UX and Conversion Review

## High-impact updates

### 1. Make the first-run promise clearer

The login and signup screens are clean, but they do not yet explain the outcome strongly enough. Add a short proof-oriented line like "Build your daily calorie target in under a minute" and one or two trust anchors such as "grams, macros, and meal logging without ads or clutter."

### 2. Show target logic after onboarding

After calculating targets, present a lightweight explanation card:

- Daily calories
- Protein target
- Carb target
- Fat target
- Why those numbers were chosen

This gives users confidence instead of making the numbers feel arbitrary.

### 3. Improve the empty dashboard state

The dashboard is strongest once it has data. For first-day users, add a stronger empty-state CTA near breakfast or at the top:

- "Log your first meal"
- "Search common foods"
- "Start with breakfast"

### 4. Make search feel faster

Search currently waits for typing and then swaps states. Add one or more of these:

- Debounce input slightly
- Show popular starter foods before the first search
- Add recent foods after the first few logs

### 5. Reduce friction on amount entry

Logging by grams is clean, but beginners often want shortcuts. Add chips for common serving amounts:

- 50 g
- 100 g
- 150 g
- 1 serving

### 6. Add trust and recovery to auth

Before launch, add:

- Forgot password
- Email verification guidance
- Better human-friendly auth errors

## Visual polish suggestions

- Replace the default launcher icon with a more distinctive mark
- Add lightweight illustration or accent art to auth screens
- Make macro colors more ownable so screenshots look recognizable in stores
- Consider a slightly more distinctive type pairing than plain Inter everywhere

## Suggested order

1. Auth trust and recovery
2. Dashboard empty-state CTA
3. Target explanation after onboarding
4. Search speed and recents
5. Serving shortcuts
