alter table public.profiles
  add column if not exists display_name text default '',
  add column if not exists calorie_target integer not null default 2000,
  add column if not exists protein_target integer not null default 150,
  add column if not exists carbs_target integer not null default 250,
  add column if not exists fat_target integer not null default 65,
  add column if not exists age integer,
  add column if not exists weight_kg numeric,
  add column if not exists height_cm numeric,
  add column if not exists activity_level text not null default 'moderate',
  add column if not exists goal text not null default 'maintain',
  add column if not exists dietary_preferences text[] not null default '{}'::text[],
  add column if not exists unit_system text not null default 'imperial',
  add column if not exists is_premium boolean not null default false,
  add column if not exists premium_expires_at timestamptz;

update public.profiles
set
  display_name = coalesce(nullif(display_name, ''), coalesce(username, '')),
  calorie_target = coalesce(calorie_target, 2000),
  protein_target = coalesce(protein_target, 150),
  carbs_target = coalesce(carbs_target, 250),
  fat_target = coalesce(fat_target, 65),
  activity_level = coalesce(activity_level, 'moderate'),
  goal = coalesce(goal, 'maintain'),
  dietary_preferences = coalesce(dietary_preferences, '{}'::text[]),
  unit_system = coalesce(unit_system, 'imperial'),
  is_premium = coalesce(is_premium, false)
where true;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_activity_level_check'
  ) then
    alter table public.profiles
      add constraint profiles_activity_level_check
      check (activity_level in ('sedentary', 'light', 'moderate', 'active', 'veryActive'));
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_goal_check'
  ) then
    alter table public.profiles
      add constraint profiles_goal_check
      check (goal in ('lose', 'maintain', 'gain'));
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_unit_system_check'
  ) then
    alter table public.profiles
      add constraint profiles_unit_system_check
      check (unit_system in ('imperial', 'metric'));
  end if;
end $$;

create index if not exists idx_community_reports_recipe_id
  on public.community_reports(recipe_id);

create index if not exists idx_community_reports_user_id
  on public.community_reports(user_id);

create index if not exists idx_household_members_user_id
  on public.household_members(user_id);

create index if not exists idx_meal_plan_entries_recipe_id
  on public.meal_plan_entries(recipe_id);

create index if not exists idx_shopping_lists_meal_plan_id
  on public.shopping_lists(meal_plan_id);

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'community_reports'
      and policyname = 'Users can read own reports'
  ) then
    create policy "Users can read own reports"
      on public.community_reports
      for select
      to authenticated
      using ((select auth.uid()) = user_id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'community_reports'
      and policyname = 'Users can create own reports'
  ) then
    create policy "Users can create own reports"
      on public.community_reports
      for insert
      to authenticated
      with check ((select auth.uid()) = user_id);
  end if;
end $$;
