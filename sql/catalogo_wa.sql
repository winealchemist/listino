-- Catalogo pubblico (link Instagram): stessi dati di listino_wa ma SENZA prezzi,
-- promo e condizioni commerciali, e solo i vini visibili nel catalogo.
-- Da eseguire una volta in Supabase → SQL Editor.
create or replace function public.catalogo_wa()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  with d as (select public.listino_wa()::jsonb as j)
  select (d.j - 'cfg' - 'vini') || jsonb_build_object(
    'cfg',  coalesce(d.j->'cfg', '{}'::jsonb) - 'cond',
    'vini', coalesce((
      select jsonb_agg(v - array['pr','promo','pn','pm','pf','ns','max','cond'])
      from jsonb_array_elements(d.j->'vini') v
      where coalesce((v->>'lc')::boolean, true)
    ), '[]'::jsonb))
  from d;
$$;

grant execute on function public.catalogo_wa() to anon, authenticated;
