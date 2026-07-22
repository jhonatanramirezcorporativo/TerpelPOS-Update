-- RLS para public.compilados. La tabla original (supabase_compilados.sql)
-- no traía políticas; si RLS quedó habilitado sin ninguna policy, TODO
-- insert/update queda bloqueado por defecto (por eso el error
-- "new row violates row-level security policy for table \"compilados\"").
--
-- Mismo criterio que el resto de la app: cualquier autenticado lee,
-- solo admins (según usuarios_roles) suben/editan/borran metadatos.

alter table public.compilados enable row level security;

drop policy if exists compilados_select on public.compilados;
create policy compilados_select
  on public.compilados for select
  to authenticated
  using (true);

drop policy if exists compilados_admin_write on public.compilados;
create policy compilados_admin_write
  on public.compilados for all
  to authenticated
  using (exists (
    select 1 from public.usuarios_roles ur
    where lower(ur.email) = lower(auth.jwt() ->> 'email') and ur.rol = 'admin'
  ))
  with check (exists (
    select 1 from public.usuarios_roles ur
    where lower(ur.email) = lower(auth.jwt() ->> 'email') and ur.rol = 'admin'
  ));

-- downloadCompiled() en index.html necesita subir "descargas" en 1 para
-- CUALQUIER usuario (no solo admins) al descargar un archivo. En vez de
-- abrir una policy de UPDATE genérica (que dejaría a cualquiera editar
-- tipo/version/nombre del compilado vía la API), se expone una función
-- puntual que solo incrementa ese contador.
create or replace function public.increment_compilado_descargas(compilado_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update public.compilados
  set descargas = coalesce(descargas, 0) + 1
  where id = compilado_id;
$$;

grant execute on function public.increment_compilado_descargas(uuid) to authenticated;
