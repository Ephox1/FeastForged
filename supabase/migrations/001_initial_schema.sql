-- FeastForged initial schema
-- Migration: 001_initial_schema

-- ──────────────────────────────────────────────────────────────────────────────
-- user_profiles
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email                 TEXT NOT NULL,
    display_name          TEXT,
    age                   INTEGER CHECK (age > 0 AND age < 150),
    weight_kg             NUMERIC(6, 2) CHECK (weight_kg > 0),
    height_cm             NUMERIC(6, 2) CHECK (height_cm > 0),
    activity_level        TEXT NOT NULL DEFAULT 'moderate'
                            CHECK (activity_level IN ('sedentary','light','moderate','active','veryActive')),
    goal                  TEXT NOT NULL DEFAULT 'maintain'
                            CHECK (goal IN ('lose','maintain','gain')),
    daily_calorie_target  INTEGER NOT NULL CHECK (daily_calorie_target > 0),
    daily_protein_target  INTEGER NOT NULL DEFAULT 150,
    daily_carb_target     INTEGER NOT NULL DEFAULT 250,
    daily_fat_target      INTEGER NOT NULL DEFAULT 65,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ
);

-- RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
    ON public.user_profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.user_profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete own profile"
    ON public.user_profiles FOR DELETE
    USING (auth.uid() = id);

-- ──────────────────────────────────────────────────────────────────────────────
-- food_items
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.food_items (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                  TEXT NOT NULL,
    brand                 TEXT,
    calories_per_100g     NUMERIC(7, 2) NOT NULL CHECK (calories_per_100g >= 0),
    protein_per_100g      NUMERIC(6, 2) NOT NULL DEFAULT 0 CHECK (protein_per_100g >= 0),
    carbs_per_100g        NUMERIC(6, 2) NOT NULL DEFAULT 0 CHECK (carbs_per_100g >= 0),
    fat_per_100g          NUMERIC(6, 2) NOT NULL DEFAULT 0 CHECK (fat_per_100g >= 0),
    fiber_per_100g        NUMERIC(6, 2) NOT NULL DEFAULT 0 CHECK (fiber_per_100g >= 0),
    sugar_per_100g        NUMERIC(6, 2) NOT NULL DEFAULT 0 CHECK (sugar_per_100g >= 0),
    serving_unit          TEXT,
    default_serving_grams NUMERIC(6, 2) NOT NULL DEFAULT 100,
    is_custom             BOOLEAN NOT NULL DEFAULT false,
    user_id               UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_food_items_name ON public.food_items USING gin (to_tsvector('english', name));
CREATE INDEX idx_food_items_user_id ON public.food_items (user_id) WHERE is_custom = true;

-- RLS
ALTER TABLE public.food_items ENABLE ROW LEVEL SECURITY;

-- Public foods readable by anyone authenticated
CREATE POLICY "Authenticated users can read public foods"
    ON public.food_items FOR SELECT
    USING (auth.role() = 'authenticated' AND (is_custom = false OR user_id = auth.uid()));

-- Only owners can manage custom foods
CREATE POLICY "Users can insert own custom foods"
    ON public.food_items FOR INSERT
    WITH CHECK (auth.uid() = user_id AND is_custom = true);

CREATE POLICY "Users can update own custom foods"
    ON public.food_items FOR UPDATE
    USING (auth.uid() = user_id AND is_custom = true)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own custom foods"
    ON public.food_items FOR DELETE
    USING (auth.uid() = user_id AND is_custom = true);

-- ──────────────────────────────────────────────────────────────────────────────
-- meal_log_entries
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.meal_log_entries (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    food_item_id   UUID REFERENCES public.food_items(id),
    food_name      TEXT NOT NULL,
    meal_type      TEXT NOT NULL
                     CHECK (meal_type IN ('breakfast','lunch','dinner','snack','other')),
    amount_grams   NUMERIC(7, 2) NOT NULL CHECK (amount_grams > 0),
    calories       NUMERIC(8, 2) NOT NULL CHECK (calories >= 0),
    protein        NUMERIC(7, 2) NOT NULL DEFAULT 0 CHECK (protein >= 0),
    carbs          NUMERIC(7, 2) NOT NULL DEFAULT 0 CHECK (carbs >= 0),
    fat            NUMERIC(7, 2) NOT NULL DEFAULT 0 CHECK (fat >= 0),
    logged_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_meal_log_user_date
    ON public.meal_log_entries (user_id, logged_at DESC);

-- RLS
ALTER TABLE public.meal_log_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own log entries"
    ON public.meal_log_entries FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own log entries"
    ON public.meal_log_entries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own log entries"
    ON public.meal_log_entries FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own log entries"
    ON public.meal_log_entries FOR DELETE
    USING (auth.uid() = user_id);

-- ──────────────────────────────────────────────────────────────────────────────
-- updated_at trigger for user_profiles
-- ──────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_user_profiles_updated
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
