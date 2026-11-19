create table public.gastos (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  monto numeric(12,2) not null check (monto > 0),
  descripcion text not null check (char_length(descripcion) <= 100),
  fecha timestamptz not null,
  categoria_id text not null,
  creado_en timestamptz not null default now()
);

alter table public.gastos enable row level security;

create policy "ver propios" on public.gastos
  for select using (auth.uid() = user_id);
create policy "insertar propios" on public.gastos
  for insert with check (auth.uid() = user_id);
create policy "actualizar propios" on public.gastos
  for update using (auth.uid() = user_id);
create policy "eliminar propios" on public.gastos
  for delete using (auth.uid() = user_id);