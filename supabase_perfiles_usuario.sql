-- Datos de perfil que cada usuario administra sobre sí mismo (ej: teléfono).
-- Separado de usuarios_roles porque ese lo administran los admins; este lo
-- edita cada usuario sobre su propia fila únicamente.

create table if not exists public.perfiles_usuario (
  email text primary key,
  telefono text,
  updated_at timestamptz not null default now()
);

alter table public.perfiles_usuario enable row level security;

drop policy if exists perfiles_usuario_self_select on public.perfiles_usuario;
create policy perfiles_usuario_self_select
  on public.perfiles_usuario for select
  to authenticated
  using (lower(email) = lower(auth.jwt() ->> 'email'));

drop policy if exists perfiles_usuario_self_insert on public.perfiles_usuario;
create policy perfiles_usuario_self_insert
  on public.perfiles_usuario for insert
  to authenticated
  with check (lower(email) = lower(auth.jwt() ->> 'email'));

drop policy if exists perfiles_usuario_self_update on public.perfiles_usuario;
create policy perfiles_usuario_self_update
  on public.perfiles_usuario for update
  to authenticated
  using (lower(email) = lower(auth.jwt() ->> 'email'))
  with check (lower(email) = lower(auth.jwt() ->> 'email'));
