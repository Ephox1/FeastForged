with current_plan as (
  select id, user_id, start_date
  from public.meal_plans
  order by start_date desc, created_at desc
  limit 1
),
seed_entries as (
  select *
  from (
    values
      (
        'c1f9a001-4f40-4b57-a001-100000000001'::uuid,
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f02'::uuid,
        2,
        'breakfast'::text,
        1,
        'Protein-forward breakfast prep for midweek mornings.'
      ),
      (
        'c1f9a001-4f40-4b57-a001-100000000002'::uuid,
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f03'::uuid,
        2,
        'lunch'::text,
        1,
        'Mediterranean-style lunch bowl with solid macros.'
      ),
      (
        'c1f9a001-4f40-4b57-a001-100000000003'::uuid,
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f08'::uuid,
        2,
        'dinner'::text,
        1,
        'Easy comfort-food dinner for tonight.'
      ),
      (
        'c1f9a001-4f40-4b57-a001-100000000004'::uuid,
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f01'::uuid,
        3,
        'breakfast'::text,
        1,
        'Overnight oats for a fast Thursday start.'
      ),
      (
        'c1f9a001-4f40-4b57-a001-100000000005'::uuid,
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f05'::uuid,
        4,
        'dinner'::text,
        1,
        'Sheet pan dinner that works well for Friday.'
      )
  ) as t(id, recipe_id, day_of_week, meal_type, servings, notes)
)
insert into public.meal_plan_entries (
  id,
  meal_plan_id,
  recipe_id,
  day_of_week,
  meal_type,
  servings,
  notes,
  created_at,
  updated_at
)
select
  seed_entries.id,
  current_plan.id,
  seed_entries.recipe_id,
  seed_entries.day_of_week,
  seed_entries.meal_type,
  seed_entries.servings,
  seed_entries.notes,
  now(),
  now()
from seed_entries
cross join current_plan
on conflict (id) do update
set
  meal_plan_id = excluded.meal_plan_id,
  recipe_id = excluded.recipe_id,
  day_of_week = excluded.day_of_week,
  meal_type = excluded.meal_type,
  servings = excluded.servings,
  notes = excluded.notes,
  updated_at = now();
