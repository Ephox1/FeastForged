-- Recipe foundation for the broader FeastForged / PrepPal architecture
-- Migration: 003_recipes_schema

CREATE TABLE IF NOT EXISTS public.recipes (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id                 UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title                    TEXT NOT NULL,
    description              TEXT,
    cuisine                  TEXT,
    meal_type                TEXT NOT NULL
                               CHECK (meal_type IN ('breakfast','lunch','dinner','snack')),
    difficulty               TEXT NOT NULL DEFAULT 'medium'
                               CHECK (difficulty IN ('easy','medium','hard')),
    prep_time_minutes        INTEGER NOT NULL DEFAULT 0 CHECK (prep_time_minutes >= 0),
    cook_time_minutes        INTEGER NOT NULL DEFAULT 0 CHECK (cook_time_minutes >= 0),
    servings                 INTEGER NOT NULL DEFAULT 4 CHECK (servings > 0),
    calories_per_serving     NUMERIC(8, 2) NOT NULL DEFAULT 0 CHECK (calories_per_serving >= 0),
    protein_per_serving      NUMERIC(8, 2) NOT NULL DEFAULT 0 CHECK (protein_per_serving >= 0),
    carbs_per_serving        NUMERIC(8, 2) NOT NULL DEFAULT 0 CHECK (carbs_per_serving >= 0),
    fat_per_serving          NUMERIC(8, 2) NOT NULL DEFAULT 0 CHECK (fat_per_serving >= 0),
    total_batch_weight_grams NUMERIC(10, 2) CHECK (total_batch_weight_grams > 0),
    ingredients              JSONB NOT NULL DEFAULT '[]'::jsonb,
    instructions             JSONB NOT NULL DEFAULT '[]'::jsonb,
    tags                     TEXT[] NOT NULL DEFAULT '{}',
    image_url                TEXT,
    source                   TEXT NOT NULL DEFAULT 'manual'
                               CHECK (source IN ('manual','ai_generated','ai_imported','community')),
    source_url               TEXT,
    is_published             BOOLEAN NOT NULL DEFAULT false,
    published_at             TIMESTAMPTZ,
    times_cooked             INTEGER NOT NULL DEFAULT 0 CHECK (times_cooked >= 0),
    last_cooked_at           TIMESTAMPTZ,
    is_favorite              BOOLEAN NOT NULL DEFAULT false,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at               TIMESTAMPTZ
);

CREATE INDEX idx_recipes_owner_id ON public.recipes (owner_id);
CREATE INDEX idx_recipes_meal_type ON public.recipes (meal_type);
CREATE INDEX idx_recipes_published ON public.recipes (is_published) WHERE is_published = true;
CREATE INDEX idx_recipes_tags ON public.recipes USING gin (tags);

ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners can read own recipes"
    ON public.recipes FOR SELECT
    USING (auth.uid() = owner_id OR is_published = true);

CREATE POLICY "Owners can insert own recipes"
    ON public.recipes FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update own recipes"
    ON public.recipes FOR UPDATE
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can delete own recipes"
    ON public.recipes FOR DELETE
    USING (auth.uid() = owner_id);

CREATE TRIGGER on_recipes_updated
    BEFORE UPDATE ON public.recipes
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
