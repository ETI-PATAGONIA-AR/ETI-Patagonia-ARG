-- =============================================================
-- ETI Patagonia — Esquema de Supabase
-- Ejecutar esto en: SQL Editor > New Query
-- =============================================================

-- 1. TABLA DE CONTENIDOS (lo que creás desde el Editor)
create table if not exists contents (
  id uuid default gen_random_uuid() primary key,
  title text not null default 'Sin título',
  section text not null check (section in ('aplicaciones','proyectos','arduino','docentes','uplc','foro')),
  content text default '',
  excerpt text default '',
  author text default '',
  tags text default '',
  status text default 'published' check (status in ('draft','published')),
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  user_id uuid references auth.users(id)
);

-- 2. TABLA DE PREGUNTAS DEL FORO
create table if not exists questions (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  content text default '',
  section text not null,
  author text not null,
  user_id uuid references auth.users(id),
  resolved boolean default false,
  created_at timestamptz default now()
);

-- 3. TABLA DE RESPUESTAS
create table if not exists answers (
  id uuid default gen_random_uuid() primary key,
  question_id uuid references questions(id) on delete cascade,
  content text not null,
  author text not null,
  user_id uuid references auth.users(id),
  created_at timestamptz default now()
);

-- 4. ACTIVAR ROW LEVEL SECURITY
alter table contents enable row level security;
alter table questions enable row level security;
alter table answers enable row level security;

-- 5. POLÍTICAS DE SEGURIDAD

-- CONTENIDOS:
-- Cualquiera (incluso sin login) puede ver contenido publicado
drop policy if exists "Anyone can view published" on contents;
create policy "Anyone can view published" on contents
  for select using (status = 'published');

-- Usuarios autenticados pueden ver todo (incluyendo borradores)
drop policy if exists "Auth users can view all" on contents;
create policy "Auth users can view all" on contents
  for select to authenticated using (true);

-- Solo el dueño puede insertar contenido
drop policy if exists "Auth users can insert own" on contents;
create policy "Auth users can insert own" on contents
  for insert to authenticated with check (auth.uid() = user_id);

-- Solo el dueño puede actualizar su contenido
drop policy if exists "Auth users can update own" on contents;
create policy "Auth users can update own" on contents
  for update to authenticated using (auth.uid() = user_id);

-- Solo el dueño puede eliminar su contenido
drop policy if exists "Auth users can delete own" on contents;
create policy "Auth users can delete own" on contents
  for delete to authenticated using (auth.uid() = user_id);

-- FORO (PREGUNTAS):
-- Usuarios autenticados pueden ver todas las preguntas
drop policy if exists "Anyone can view questions" on questions;
create policy "Anyone can view questions" on questions
  for select to authenticated using (true);

-- Usuarios autenticados pueden crear preguntas
drop policy if exists "Auth users can insert questions" on questions;
create policy "Auth users can insert questions" on questions
  for insert to authenticated with check (auth.uid() = user_id);

-- FORO (RESPUESTAS):
-- Usuarios autenticados pueden ver todas las respuestas
drop policy if exists "Anyone can view answers" on answers;
create policy "Anyone can view answers" on answers
  for select to authenticated using (true);

-- Usuarios autenticados pueden responder
drop policy if exists "Auth users can insert answers" on answers;
create policy "Auth users can insert answers" on answers
  for insert to authenticated with check (auth.uid() = user_id);

-- El dueño de la respuesta puede actualizarla
drop policy if exists "Auth users can update own answers" on answers;
create policy "Auth users can update own answers" on answers
  for update to authenticated using (auth.uid() = user_id);
