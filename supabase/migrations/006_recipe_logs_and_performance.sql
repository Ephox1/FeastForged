create table if not exists public.recipe_log_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  recipe_id uuid not null references public.recipes(id) on delete cascade,
  meal_plan_entry_id uuid references public.meal_plan_entries(id) on delete set null,
  meal_type text not null check (meal_type in ('breakfast', 'lunch', 'dinner', 'snack', 'other')),
  recipe_title text not null,
  servings numeric(6,2) not null default 1 check (servings > 0),
  calories numeric(10,2) not null default 0,
  protein_g numeric(10,2) not null default 0,
  carbs_g numeric(10,2) not null default 0,
  fat_g numeric(10,2) not null default 0,
  logged_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists idx_recipe_log_entries_user_logged_at
  on public.recipe_log_entries(user_id, logged_at desc);

create index if not exists idx_recipe_log_entries_recipe_id
  on public.recipe_log_entries(recipe_id);

create index if not exists idx_recipe_log_entries_meal_plan_entry_id
  on public.recipe_log_entries(meal_plan_entry_id);

create index if not exists idx_community_reviews_user_id
  on public.community_reviews(user_id);

alter table public.recipe_log_entries enable row level security;

drop policy if exists "Users can read own recipe logs" on public.recipe_log_entries;
create policy "Users can read own recipe logs"
  on public.recipe_log_entries
  for select
  using (user_id = (select auth.uid()));

drop policy if exists "Users can create own recipe logs" on public.recipe_log_entries;
create policy "Users can create own recipe logs"
  on public.recipe_log_entries
  for insert
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can update own recipe logs" on public.recipe_log_entries;
create policy "Users can update own recipe logs"
  on public.recipe_log_entries
  for update
  using (user_id = (select auth.uid()));

drop policy if exists "Users can delete own recipe logs" on public.recipe_log_entries;
create policy "Users can delete own recipe logs"
  on public.recipe_log_entries
  for delete
  using (user_id = (select auth.uid()));

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
  on public.profiles
  for insert
  with check ((select auth.uid()) = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles
  for update
  using ((select auth.uid()) = id);

drop policy if exists "Users can create recipes" on public.recipes;
create policy "Users can create recipes"
  on public.recipes
  for insert
  with check (created_by = (select auth.uid()));

drop policy if exists "Users can delete own recipes" on public.recipes;
create policy "Users can delete own recipes"
  on public.recipes
  for delete
  using (created_by = (select auth.uid()));

drop policy if exists "Users can read own recipes" on public.recipes;
create policy "Users can read own recipes"
  on public.recipes
  for select
  using ((created_by = (select auth.uid())) or (is_public = true));

drop policy if exists "Users can update own recipes" on public.recipes;
create policy "Users can update own recipes"
  on public.recipes
  for update
  using (created_by = (select auth.uid()));

drop policy if exists "Users can create meal plans" on public.meal_plans;
create policy "Users can create meal plans"
  on public.meal_plans
  for insert
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can delete own meal plans" on public.meal_plans;
create policy "Users can delete own meal plans"
  on public.meal_plans
  for delete
  using (user_id = (select auth.uid()));

drop policy if exists "Users can read own meal plans" on public.meal_plans;
create policy "Users can read own meal plans"
  on public.meal_plans
  for select
  using (user_id = (select auth.uid()));

drop policy if exists "Users can update own meal plans" on public.meal_plans;
create policy "Users can update own meal plans"
  on public.meal_plans
  for update
  using (user_id = (select auth.uid()));

drop policy if exists "Users can create meal plan entries" on public.meal_plan_entries;
create policy "Users can create meal plan entries"
  on public.meal_plan_entries
  for insert
  with check (
    meal_plan_id in (
      select meal_plans.id
      from public.meal_plans
      where meal_plans.user_id = (select auth.uid())
    )
  );

drop policy if exists "Users can delete own meal plan entries" on public.meal_plan_entries;
create policy "Users can delete own meal plan entries"
  on public.meal_plan_entries
  for delete
  using (
    meal_plan_id in (
      select meal_plans.id
      from public.meal_plans
      where meal_plans.user_id = (select auth.uid())
    )
  );

drop policy if exists "Users can read own meal plan entries" on public.meal_plan_entries;
create policy "Users can read own meal plan entries"
  on public.meal_plan_entries
  for select
  using (
    meal_plan_id in (
      select meal_plans.id
      from public.meal_plans
      where meal_plans.user_id = (select auth.uid())
    )
  );

drop policy if exists "Users can update own meal plan entries" on public.meal_plan_entries;
create policy "Users can update own meal plan entries"
  on public.meal_plan_entries
  for update
  using (
    meal_plan_id in (
      select meal_plans.id
      from public.meal_plans
      where meal_plans.user_id = (select auth.uid())
    )
  );

drop policy if exists "Users can create shopping lists" on public.shopping_lists;
create policy "Users can create shopping lists"
  on public.shopping_lists
  for insert
  with check (
    meal_plan_id in (
      select meal_plans.id
      from public.meal_plans
      where meal_plans.user_id = (select auth.uid())
    )
  );

drop policy if exists "Users can read own shopping lists" on public.shopping_lists;
create policy "Users can read own shopping lists"
  on public.shopping_lists
  for select
  using (
    meal_plan_id in (
      select meal_plans.id
      from public.meal_plans
      where meal_plans.user_id = (select auth.uid())
    )
  );

drop policy if exists "Users can create shopping list items" on public.shopping_list_items;
create policy "Users can create shopping list items"
  on public.shopping_list_items
  for insert
  with check (
    shopping_list_id in (
      select shopping_lists.id
      from public.shopping_lists
      where shopping_lists.meal_plan_id in (
        select meal_plans.id
        from public.meal_plans
        where meal_plans.user_id = (select auth.uid())
      )
    )
  );

drop policy if exists "Users can delete own shopping list items" on public.shopping_list_items;
create policy "Users can delete own shopping list items"
  on public.shopping_list_items
  for delete
  using (
    shopping_list_id in (
      select shopping_lists.id
      from public.shopping_lists
      where shopping_lists.meal_plan_id in (
        select meal_plans.id
        from public.meal_plans
        where meal_plans.user_id = (select auth.uid())
      )
    )
  );

drop policy if exists "Users can read own shopping list items" on public.shopping_list_items;
create policy "Users can read own shopping list items"
  on public.shopping_list_items
  for select
  using (
    shopping_list_id in (
      select shopping_lists.id
      from public.shopping_lists
      where shopping_lists.meal_plan_id in (
        select meal_plans.id
        from public.meal_plans
        where meal_plans.user_id = (select auth.uid())
      )
    )
  );

drop policy if exists "Users can update own shopping list items" on public.shopping_list_items;
create policy "Users can update own shopping list items"
  on public.shopping_list_items
  for update
  using (
    shopping_list_id in (
      select shopping_lists.id
      from public.shopping_lists
      where shopping_lists.meal_plan_id in (
        select meal_plans.id
        from public.meal_plans
        where meal_plans.user_id = (select auth.uid())
      )
    )
  );

drop policy if exists "Users can delete own household members" on public.household_members;
create policy "Users can delete own household members"
  on public.household_members
  for delete
  using (user_id = (select auth.uid()));

drop policy if exists "Users can insert own household members" on public.household_members;
create policy "Users can insert own household members"
  on public.household_members
  for insert
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can read own household members" on public.household_members;
create policy "Users can read own household members"
  on public.household_members
  for select
  using (user_id = (select auth.uid()));

drop policy if exists "Users can update own household members" on public.household_members;
create policy "Users can update own household members"
  on public.household_members
  for update
  using (user_id = (select auth.uid()));

drop policy if exists "Users can delete own ratings" on public.community_ratings;
create policy "Users can delete own ratings"
  on public.community_ratings
  for delete
  using (user_id = (select auth.uid()));

drop policy if exists "Users can insert own ratings" on public.community_ratings;
create policy "Users can insert own ratings"
  on public.community_ratings
  for insert
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can update own ratings" on public.community_ratings;
create policy "Users can update own ratings"
  on public.community_ratings
  for update
  using (user_id = (select auth.uid()));

drop policy if exists "Users can delete own reviews" on public.community_reviews;
create policy "Users can delete own reviews"
  on public.community_reviews
  for delete
  using (user_id = (select auth.uid()));

drop policy if exists "Users can insert own reviews" on public.community_reviews;
create policy "Users can insert own reviews"
  on public.community_reviews
  for insert
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can update own reviews" on public.community_reviews;
create policy "Users can update own reviews"
  on public.community_reviews
  for update
  using (user_id = (select auth.uid()));

drop policy if exists "Users can delete own saves" on public.community_saves;
create policy "Users can delete own saves"
  on public.community_saves
  for delete
  using (user_id = (select auth.uid()));

drop policy if exists "Users can insert own saves" on public.community_saves;
create policy "Users can insert own saves"
  on public.community_saves
  for insert
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can read own saves" on public.community_saves;
create policy "Users can read own saves"
  on public.community_saves
  for select
  using (user_id = (select auth.uid()));

drop policy if exists "Users can insert own ai usage" on public.ai_usage;
create policy "Users can insert own ai usage"
  on public.ai_usage
  for insert
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can read own ai usage" on public.ai_usage;
create policy "Users can read own ai usage"
  on public.ai_usage
  for select
  using (user_id = (select auth.uid()));
