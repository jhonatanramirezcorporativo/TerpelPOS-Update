alter table public.actualizaciones
  add column if not exists tipo_registro text default 'Version',
  add column if not exists fix_tipo text,
  add column if not exists fecha_programada date,
  add column if not exists codigo_unico text,
  add column if not exists regional text,
  add column if not exists cronograma_estado text,
  add column if not exists nombre_eds text,
  add column if not exists agente text;

create index if not exists idx_actualizaciones_tipo_registro
  on public.actualizaciones (tipo_registro);

create index if not exists idx_actualizaciones_fix_tipo
  on public.actualizaciones (fix_tipo);

create index if not exists idx_actualizaciones_fecha_programada
  on public.actualizaciones (fecha_programada);
