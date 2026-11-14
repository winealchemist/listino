-- Impostazioni per singolo produttore (backoffice → Modifica produttore):
-- ordine delle referenze e nota per i clienti. Da eseguire una volta in Supabase → SQL Editor.
alter table crm.produttori
  add column if not exists ordine_vini   text,
  add column if not exists nota          text,
  add column if not exists nota_catalogo boolean not null default false;

create or replace function public.listino_produttori_extra()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(jsonb_object_agg(nome, jsonb_strip_nulls(jsonb_build_object(
           'ov', ordine_vini, 'nota', nota, 'nc', case when nota_catalogo then true end))), '{}'::jsonb)
  from crm.produttori
  where ordine_vini is not null or nota is not null;
$$;

grant execute on function public.listino_produttori_extra() to anon, authenticated;
notify pgrst, 'reload schema';
