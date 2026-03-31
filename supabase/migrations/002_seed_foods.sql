-- Seed a basic food database
-- Migration: 002_seed_foods

INSERT INTO public.food_items (name, brand, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, default_serving_grams, is_custom)
VALUES
  -- Proteins
  ('Chicken Breast (cooked)', NULL, 165, 31.0, 0.0, 3.6, 0.0, 150, false),
  ('Ground Beef 80/20 (cooked)', NULL, 254, 26.0, 0.0, 17.0, 0.0, 150, false),
  ('Salmon (cooked)', NULL, 208, 20.4, 0.0, 13.4, 0.0, 150, false),
  ('Tuna (canned in water)', NULL, 116, 25.5, 0.0, 0.8, 0.0, 85, false),
  ('Eggs (whole, large)', NULL, 143, 12.6, 0.7, 9.5, 0.0, 50, false),
  ('Greek Yogurt (plain, 0%)', NULL, 59, 10.2, 3.6, 0.4, 0.0, 170, false),
  ('Cottage Cheese (1%)', NULL, 72, 12.4, 2.7, 1.0, 0.0, 113, false),
  ('Whey Protein Powder', NULL, 380, 75.0, 8.0, 5.0, 0.0, 30, false),

  -- Carbohydrates
  ('White Rice (cooked)', NULL, 130, 2.7, 28.2, 0.3, 0.4, 200, false),
  ('Brown Rice (cooked)', NULL, 112, 2.6, 23.5, 0.9, 1.8, 200, false),
  ('Oats (rolled, dry)', NULL, 389, 16.9, 66.3, 6.9, 10.6, 80, false),
  ('Sweet Potato (baked)', NULL, 103, 2.3, 23.6, 0.1, 3.8, 130, false),
  ('White Bread', NULL, 265, 9.0, 49.0, 3.2, 2.7, 30, false),
  ('Whole Wheat Bread', NULL, 247, 13.0, 41.0, 3.4, 7.0, 30, false),
  ('Banana', NULL, 89, 1.1, 23.0, 0.3, 2.6, 120, false),
  ('Apple', NULL, 52, 0.3, 13.8, 0.2, 2.4, 180, false),
  ('Pasta (cooked)', NULL, 158, 5.8, 30.9, 0.9, 1.8, 200, false),
  ('Potato (boiled)', NULL, 87, 1.9, 20.1, 0.1, 1.8, 150, false),

  -- Fats
  ('Avocado', NULL, 160, 2.0, 8.5, 14.7, 6.7, 150, false),
  ('Almonds', NULL, 579, 21.2, 21.6, 49.9, 12.5, 30, false),
  ('Peanut Butter', NULL, 588, 25.1, 20.0, 50.4, 6.0, 32, false),
  ('Olive Oil', NULL, 884, 0.0, 0.0, 100.0, 0.0, 14, false),
  ('Cheddar Cheese', NULL, 403, 25.0, 1.3, 33.1, 0.0, 28, false),

  -- Vegetables
  ('Broccoli (raw)', NULL, 34, 2.8, 6.6, 0.4, 2.6, 100, false),
  ('Spinach (raw)', NULL, 23, 2.9, 3.6, 0.4, 2.2, 100, false),
  ('Mixed Greens (salad)', NULL, 20, 1.9, 3.5, 0.2, 2.0, 85, false),
  ('Bell Pepper (red)', NULL, 31, 1.0, 6.0, 0.3, 2.1, 150, false),
  ('Broccoli (steamed)', NULL, 35, 2.4, 7.2, 0.4, 3.3, 150, false)
ON CONFLICT DO NOTHING;
