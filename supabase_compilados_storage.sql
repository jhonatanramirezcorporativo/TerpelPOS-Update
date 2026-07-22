-- Bucket de Storage para los archivos de "Compilados & Releases".
-- La tabla public.compilados (ver supabase_compilados.sql) solo guarda los
-- metadatos; los archivos en sí viven en este bucket. Si nunca se creó,
-- las subidas fallan con un error tipo "Bucket not found" aunque la tabla
-- exista y el botón "Subir Compilado" se vea bien.

insert into storage.buckets (id, name, public)
values ('compilados', 'compilados', true)
on conflict (id) do nothing;

-- Cualquiera (incluso anónimo) puede leer/descargar, porque el bucket es
-- público y downloadCompiled() usa getPublicUrl(). Solo admins pueden subir
-- o borrar objetos, igual que en la tabla de metadatos.
drop policy if exists compilados_storage_read on storage.objects;
create policy compilados_storage_read
  on storage.objects for select
  using (bucket_id = 'compilados');

drop policy if exists compilados_storage_admin_write on storage.objects;
create policy compilados_storage_admin_write
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'compilados'
    and exists (
      select 1 from public.usuarios_roles ur
      where lower(ur.email) = lower(auth.jwt() ->> 'email') and ur.rol = 'admin'
    )
  );

drop policy if exists compilados_storage_admin_delete on storage.objects;
create policy compilados_storage_admin_delete
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'compilados'
    and exists (
      select 1 from public.usuarios_roles ur
      where lower(ur.email) = lower(auth.jwt() ->> 'email') and ur.rol = 'admin'
    )
  );
