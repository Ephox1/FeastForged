with seed_owner as (
  select id
  from public.profiles
  order by created_at asc
  limit 1
),
seed_recipes as (
  select *
  from (
    values
      (
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f01'::uuid,
        'Lemon Blueberry Overnight Oats',
        'A grab-and-go breakfast with oats, Greek yogurt, chia, and blueberries.',
        10,
        0,
        2,
        780::numeric,
        42::numeric,
        104::numeric,
        20::numeric,
        jsonb_build_array(
          jsonb_build_object('name', 'Rolled oats', 'quantity', 2, 'unit', 'cups', 'category', 'Pantry'),
          jsonb_build_object('name', 'Greek yogurt', 'quantity', 1.5, 'unit', 'cups', 'category', 'Dairy'),
          jsonb_build_object('name', 'Unsweetened almond milk', 'quantity', 1.5, 'unit', 'cups', 'category', 'Dairy'),
          jsonb_build_object('name', 'Blueberries', 'quantity', 1, 'unit', 'cup', 'category', 'Produce'),
          jsonb_build_object('name', 'Chia seeds', 'quantity', 2, 'unit', 'tbsp', 'category', 'Pantry'),
          jsonb_build_object('name', 'Lemon zest', 'quantity', 1, 'unit', 'tsp', 'category', 'Produce'),
          jsonb_build_object('name', 'Honey', 'quantity', 1, 'unit', 'tbsp', 'category', 'Pantry')
        ),
        array[
          'Mix oats, yogurt, almond milk, chia, lemon zest, and honey in a bowl.',
          'Fold in half of the blueberries and portion into jars.',
          'Top with the remaining blueberries and chill overnight.'
        ]::text[],
        array['breakfast', 'meal-prep', 'high-protein', 'vegetarian']::text[],
        true,
        true,
        48,
        now() - interval '10 days'
      ),
      (
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f02'::uuid,
        'Turkey Egg White Breakfast Burritos',
        'Meal-prep burritos loaded with lean turkey, egg whites, peppers, and cheese.',
        20,
        15,
        4,
        1680::numeric,
        164::numeric,
        120::numeric,
        52::numeric,
        jsonb_build_array(
          jsonb_build_object('name', 'Lean ground turkey', 'quantity', 1, 'unit', 'lb', 'category', 'Protein'),
          jsonb_build_object('name', 'Egg whites', 'quantity', 2, 'unit', 'cups', 'category', 'Protein'),
          jsonb_build_object('name', 'Bell peppers', 'quantity', 2, 'unit', 'whole', 'category', 'Produce'),
          jsonb_build_object('name', 'Shredded cheddar', 'quantity', 1, 'unit', 'cup', 'category', 'Dairy'),
          jsonb_build_object('name', 'Whole wheat tortillas', 'quantity', 4, 'unit', 'whole', 'category', 'Pantry'),
          jsonb_build_object('name', 'Salsa', 'quantity', 0.5, 'unit', 'cup', 'category', 'Pantry')
        ),
        array[
          'Brown the turkey in a skillet and season well.',
          'Cook peppers until softened, then add egg whites and scramble until set.',
          'Assemble tortillas with turkey, egg mixture, cheese, and salsa.',
          'Wrap tightly and refrigerate or freeze for later.'
        ]::text[],
        array['breakfast', 'meal-prep', 'high-protein']::text[],
        true,
        true,
        71,
        now() - interval '9 days'
      ),
      (
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f03'::uuid,
        'Greek Chicken Power Bowls',
        'Chicken, rice, cucumbers, tomatoes, feta, and tzatziki for an easy lunch prep.',
        20,
        20,
        4,
        2480::numeric,
        224::numeric,
        220::numeric,
        72::numeric,
        jsonb_build_array(
          jsonb_build_object('name', 'Chicken breast', 'quantity', 2, 'unit', 'lb', 'category', 'Protein'),
          jsonb_build_object('name', 'Cooked jasmine rice', 'quantity', 6, 'unit', 'cups', 'category', 'Pantry'),
          jsonb_build_object('name', 'Cucumber', 'quantity', 1, 'unit', 'whole', 'category', 'Produce'),
          jsonb_build_object('name', 'Cherry tomatoes', 'quantity', 2, 'unit', 'cups', 'category', 'Produce'),
          jsonb_build_object('name', 'Feta', 'quantity', 1, 'unit', 'cup', 'category', 'Dairy'),
          jsonb_build_object('name', 'Tzatziki', 'quantity', 1, 'unit', 'cup', 'category', 'Sauce'),
          jsonb_build_object('name', 'Olive oil', 'quantity', 2, 'unit', 'tbsp', 'category', 'Pantry')
        ),
        array[
          'Season and cook the chicken until golden and cooked through.',
          'Slice the chicken and divide rice among four bowls.',
          'Top with cucumber, tomatoes, feta, and chicken.',
          'Finish each bowl with tzatziki and a drizzle of olive oil.'
        ]::text[],
        array['lunch', 'meal-prep', 'high-protein', 'mediterranean']::text[],
        true,
        true,
        126,
        now() - interval '8 days'
      ),
      (
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f04'::uuid,
        'Honey Sriracha Salmon Rice Bowls',
        'Sweet-spicy salmon with edamame, rice, and crunchy vegetables.',
        15,
        18,
        4,
        2360::numeric,
        152::numeric,
        212::numeric,
        92::numeric,
        jsonb_build_array(
          jsonb_build_object('name', 'Salmon fillets', 'quantity', 1.5, 'unit', 'lb', 'category', 'Protein'),
          jsonb_build_object('name', 'Cooked rice', 'quantity', 5, 'unit', 'cups', 'category', 'Pantry'),
          jsonb_build_object('name', 'Shelled edamame', 'quantity', 2, 'unit', 'cups', 'category', 'Frozen'),
          jsonb_build_object('name', 'Shredded carrots', 'quantity', 2, 'unit', 'cups', 'category', 'Produce'),
          jsonb_build_object('name', 'Cucumber', 'quantity', 1, 'unit', 'whole', 'category', 'Produce'),
          jsonb_build_object('name', 'Honey sriracha sauce', 'quantity', 0.5, 'unit', 'cup', 'category', 'Sauce')
        ),
        array[
          'Brush salmon with honey sriracha sauce and roast until flaky.',
          'Warm the rice and edamame.',
          'Flake the salmon into portions and assemble bowls with vegetables.',
          'Spoon the remaining sauce over the top before serving.'
        ]::text[],
        array['dinner', 'high-protein', 'seafood']::text[],
        true,
        true,
        88,
        now() - interval '7 days'
      ),
      (
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f05'::uuid,
        'Sheet Pan Steak and Sweet Potatoes',
        'A high-protein dinner with roasted steak bites, sweet potatoes, and broccoli.',
        15,
        25,
        4,
        2320::numeric,
        188::numeric,
        176::numeric,
        92::numeric,
        jsonb_build_array(
          jsonb_build_object('name', 'Sirloin steak', 'quantity', 2, 'unit', 'lb', 'category', 'Protein'),
          jsonb_build_object('name', 'Sweet potatoes', 'quantity', 3, 'unit', 'whole', 'category', 'Produce'),
          jsonb_build_object('name', 'Broccoli florets', 'quantity', 6, 'unit', 'cups', 'category', 'Produce'),
          jsonb_build_object('name', 'Olive oil', 'quantity', 2, 'unit', 'tbsp', 'category', 'Pantry'),
          jsonb_build_object('name', 'Garlic powder', 'quantity', 2, 'unit', 'tsp', 'category', 'Pantry')
        ),
        array[
          'Toss sweet potatoes and broccoli with olive oil and seasonings.',
          'Roast vegetables until nearly tender.',
          'Add seasoned steak bites to the pan and roast until the steak reaches your preferred doneness.',
          'Serve or portion for meal prep.'
        ]::text[],
        array['dinner', 'meal-prep', 'high-protein']::text[],
        true,
        true,
        64,
        now() - interval '6 days'
      ),
      (
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f06'::uuid,
        'Buffalo Chicken Crunch Wrap',
        'A fast lunch wrap with buffalo chicken, crunchy lettuce, and Greek yogurt ranch.',
        10,
        10,
        2,
        1020::numeric,
        94::numeric,
        62::numeric,
        40::numeric,
        jsonb_build_array(
          jsonb_build_object('name', 'Cooked shredded chicken', 'quantity', 3, 'unit', 'cups', 'category', 'Protein'),
          jsonb_build_object('name', 'Buffalo sauce', 'quantity', 0.25, 'unit', 'cup', 'category', 'Sauce'),
          jsonb_build_object('name', 'High-protein tortillas', 'quantity', 2, 'unit', 'whole', 'category', 'Pantry'),
          jsonb_build_object('name', 'Shredded lettuce', 'quantity', 2, 'unit', 'cups', 'category', 'Produce'),
          jsonb_build_object('name', 'Tomatoes', 'quantity', 1, 'unit', 'cup', 'category', 'Produce'),
          jsonb_build_object('name', 'Greek yogurt ranch', 'quantity', 0.25, 'unit', 'cup', 'category', 'Sauce')
        ),
        array[
          'Toss the chicken with buffalo sauce.',
          'Warm the tortillas and layer with lettuce, tomato, chicken, and ranch.',
          'Fold tightly and toast in a skillet for a crisp finish.'
        ]::text[],
        array['lunch', 'quick', 'high-protein']::text[],
        true,
        true,
        37,
        now() - interval '5 days'
      ),
      (
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f07'::uuid,
        'Cottage Cheese Berry Crunch Bowl',
        'A fast snack bowl with cottage cheese, berries, granola, and almonds.',
        5,
        0,
        1,
        410::numeric,
        30::numeric,
        34::numeric,
        16::numeric,
        jsonb_build_array(
          jsonb_build_object('name', 'Low-fat cottage cheese', 'quantity', 1.25, 'unit', 'cups', 'category', 'Dairy'),
          jsonb_build_object('name', 'Mixed berries', 'quantity', 1, 'unit', 'cup', 'category', 'Produce'),
          jsonb_build_object('name', 'Granola', 'quantity', 0.25, 'unit', 'cup', 'category', 'Pantry'),
          jsonb_build_object('name', 'Sliced almonds', 'quantity', 2, 'unit', 'tbsp', 'category', 'Pantry'),
          jsonb_build_object('name', 'Cinnamon', 'quantity', 0.5, 'unit', 'tsp', 'category', 'Pantry')
        ),
        array[
          'Spoon cottage cheese into a bowl.',
          'Top with berries, granola, almonds, and cinnamon.',
          'Serve immediately.'
        ]::text[],
        array['snack', 'quick', 'high-protein', 'vegetarian']::text[],
        true,
        true,
        29,
        now() - interval '4 days'
      ),
      (
        '5c4d8b07-9b12-4f4a-bd55-3a29800f1f08'::uuid,
        'Slow Cooker Turkey Chili',
        'A hearty, high-protein chili that reheats beautifully all week.',
        20,
        240,
        6,
        2580::numeric,
        234::numeric,
        180::numeric,
        72::numeric,
        jsonb_build_array(
          jsonb_build_object('name', 'Lean ground turkey', 'quantity', 2, 'unit', 'lb', 'category', 'Protein'),
          jsonb_build_object('name', 'Kidney beans', 'quantity', 2, 'unit', 'cans', 'category', 'Pantry'),
          jsonb_build_object('name', 'Black beans', 'quantity', 2, 'unit', 'cans', 'category', 'Pantry'),
          jsonb_build_object('name', 'Crushed tomatoes', 'quantity', 2, 'unit', 'cans', 'category', 'Pantry'),
          jsonb_build_object('name', 'Onion', 'quantity', 1, 'unit', 'whole', 'category', 'Produce'),
          jsonb_build_object('name', 'Bell pepper', 'quantity', 1, 'unit', 'whole', 'category', 'Produce'),
          jsonb_build_object('name', 'Chili seasoning', 'quantity', 3, 'unit', 'tbsp', 'category', 'Pantry')
        ),
        array[
          'Brown the turkey with onion and bell pepper.',
          'Transfer to a slow cooker with beans, tomatoes, and chili seasoning.',
          'Cook on low for 4 hours or until thick and flavorful.',
          'Portion into containers and garnish as desired.'
        ]::text[],
        array['dinner', 'meal-prep', 'high-protein', 'comfort-food']::text[],
        true,
        true,
        97,
        now() - interval '3 days'
      )
  ) as t(
    id,
    title,
    description,
    prep_time_minutes,
    cook_time_minutes,
    servings,
    calories,
    protein_g,
    carbs_g,
    fat_g,
    ingredients,
    instructions,
    tags,
    is_community,
    is_public,
    downloads,
    created_at
  )
)
insert into public.recipes (
  id,
  created_by,
  title,
  description,
  prep_time_minutes,
  cook_time_minutes,
  servings,
  calories,
  protein_g,
  carbs_g,
  fat_g,
  ingredients,
  instructions,
  tags,
  is_community,
  is_public,
  downloads,
  created_at,
  updated_at
)
select
  seed_recipes.id,
  seed_owner.id,
  seed_recipes.title,
  seed_recipes.description,
  seed_recipes.prep_time_minutes,
  seed_recipes.cook_time_minutes,
  seed_recipes.servings,
  seed_recipes.calories,
  seed_recipes.protein_g,
  seed_recipes.carbs_g,
  seed_recipes.fat_g,
  seed_recipes.ingredients,
  seed_recipes.instructions,
  seed_recipes.tags,
  seed_recipes.is_community,
  seed_recipes.is_public,
  seed_recipes.downloads,
  seed_recipes.created_at,
  now()
from seed_recipes
cross join seed_owner
on conflict (id) do update
set
  created_by = excluded.created_by,
  title = excluded.title,
  description = excluded.description,
  prep_time_minutes = excluded.prep_time_minutes,
  cook_time_minutes = excluded.cook_time_minutes,
  servings = excluded.servings,
  calories = excluded.calories,
  protein_g = excluded.protein_g,
  carbs_g = excluded.carbs_g,
  fat_g = excluded.fat_g,
  ingredients = excluded.ingredients,
  instructions = excluded.instructions,
  tags = excluded.tags,
  is_community = excluded.is_community,
  is_public = excluded.is_public,
  downloads = excluded.downloads,
  updated_at = now();

insert into public.community_recipe_stats (
  recipe_id,
  average_rating,
  total_ratings,
  total_saves,
  total_reviews,
  created_at,
  updated_at
)
values
  ('5c4d8b07-9b12-4f4a-bd55-3a29800f1f01'::uuid, 4.7, 18, 24, 9, now(), now()),
  ('5c4d8b07-9b12-4f4a-bd55-3a29800f1f02'::uuid, 4.8, 26, 31, 12, now(), now()),
  ('5c4d8b07-9b12-4f4a-bd55-3a29800f1f03'::uuid, 4.9, 41, 54, 19, now(), now()),
  ('5c4d8b07-9b12-4f4a-bd55-3a29800f1f04'::uuid, 4.8, 29, 33, 11, now(), now()),
  ('5c4d8b07-9b12-4f4a-bd55-3a29800f1f05'::uuid, 4.6, 16, 20, 7, now(), now()),
  ('5c4d8b07-9b12-4f4a-bd55-3a29800f1f06'::uuid, 4.5, 11, 17, 4, now(), now()),
  ('5c4d8b07-9b12-4f4a-bd55-3a29800f1f07'::uuid, 4.7, 14, 15, 6, now(), now()),
  ('5c4d8b07-9b12-4f4a-bd55-3a29800f1f08'::uuid, 4.9, 37, 45, 16, now(), now())
on conflict (recipe_id) do update
set
  average_rating = excluded.average_rating,
  total_ratings = excluded.total_ratings,
  total_saves = excluded.total_saves,
  total_reviews = excluded.total_reviews,
  updated_at = now();
