create schema if not exists extensions;

drop extension if exists http cascade;
create extension if not exists http with schema extensions;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $function$
begin
  insert into profiles (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'user_' || left(new.id::text, 8))
  );
  return new;
end;
$function$;

create or replace function public.update_recipe_stats()
returns trigger
language plpgsql
security definer
set search_path = public
as $function$
declare
  target_recipe_id uuid;
begin
  if tg_op = 'DELETE' then
    target_recipe_id := old.recipe_id;
  else
    target_recipe_id := new.recipe_id;
  end if;

  insert into community_recipe_stats (
    recipe_id,
    average_rating,
    total_ratings,
    total_saves,
    total_reviews
  )
  values (
    target_recipe_id,
    coalesce((select avg(rating) from community_ratings where recipe_id = target_recipe_id), 0),
    (select count(*) from community_ratings where recipe_id = target_recipe_id),
    (select count(*) from community_saves where recipe_id = target_recipe_id),
    (select count(*) from community_reviews where recipe_id = target_recipe_id)
  )
  on conflict (recipe_id) do update
  set
    average_rating = coalesce((select avg(rating) from community_ratings where recipe_id = target_recipe_id), 0),
    total_ratings = (select count(*) from community_ratings where recipe_id = target_recipe_id),
    total_saves = (select count(*) from community_saves where recipe_id = target_recipe_id),
    total_reviews = (select count(*) from community_reviews where recipe_id = target_recipe_id),
    updated_at = now();

  return coalesce(new, old);
end;
$function$;
