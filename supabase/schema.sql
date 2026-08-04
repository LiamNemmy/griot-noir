-- GRIOT NOIR — Supabase schema
-- Run this first in the Supabase SQL Editor, then run seed.sql.
-- Mirrors the shape expected by FEED_SELECT / mapRow() in index.html.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------
-- people (writers, photographers, contributors, editors)
-- ---------------------------------------------------------------
create table if not exists people (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  slug        text not null unique,
  bio         text,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------
-- terms (categories + tags live in one table, distinguished by `type`)
-- ---------------------------------------------------------------
create table if not exists terms (
  id          uuid primary key default gen_random_uuid(),
  type        text not null check (type in ('category','tag')),
  slug        text not null,
  name        text not null,
  created_at  timestamptz not null default now(),
  unique (type, slug)
);

-- ---------------------------------------------------------------
-- works (articles, essays, galleries, announcements, etc.)
-- ---------------------------------------------------------------
create table if not exists works (
  id                uuid primary key default gen_random_uuid(),
  slug              text not null unique,
  title             text not null,
  subtitle          text,
  summary           text,
  type              text not null default 'article'
                       check (type in ('article','essay','gallery','announcement')),
  status            text not null default 'draft'
                       check (status in ('draft','published','archived')),
  featured          boolean not null default false,
  pinned            boolean not null default false,
  editorial_weight  integer not null default 0,
  published_at      timestamptz,
  image_url         text,
  image_alt         text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists works_status_published_idx
  on works (status, published_at desc);
create index if not exists works_pinned_weight_idx
  on works (pinned desc, editorial_weight desc, published_at desc);

-- ---------------------------------------------------------------
-- work_creators (join table: work <-> people, with role + ordering)
-- ---------------------------------------------------------------
create table if not exists work_creators (
  id          uuid primary key default gen_random_uuid(),
  work_id     uuid not null references works (id) on delete cascade,
  person_id   uuid not null references people (id) on delete cascade,
  role        text not null default 'Writer',
  "position"  integer not null default 0,
  unique (work_id, person_id, role)
);

create index if not exists work_creators_work_idx on work_creators (work_id);

-- ---------------------------------------------------------------
-- work_terms (join table: work <-> terms, i.e. categories + tags)
-- ---------------------------------------------------------------
create table if not exists work_terms (
  work_id   uuid not null references works (id) on delete cascade,
  term_id   uuid not null references terms (id) on delete cascade,
  primary key (work_id, term_id)
);

create index if not exists work_terms_work_idx on work_terms (work_id);
create index if not exists work_terms_term_idx on work_terms (term_id);

-- ---------------------------------------------------------------
-- keep updated_at fresh
-- ---------------------------------------------------------------
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists works_set_updated_at on works;
create trigger works_set_updated_at
  before update on works
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------
-- Row Level Security — public (anon) role may only ever read
-- rows that are actually published. Nothing else is exposed.
-- ---------------------------------------------------------------
alter table people        enable row level security;
alter table terms         enable row level security;
alter table works         enable row level security;
alter table work_creators enable row level security;
alter table work_terms    enable row level security;

drop policy if exists "public read people" on people;
create policy "public read people" on people
  for select using (true);

drop policy if exists "public read terms" on terms;
create policy "public read terms" on terms
  for select using (true);

drop policy if exists "public read published works" on works;
create policy "public read published works" on works
  for select using (status = 'published' and published_at <= now());

drop policy if exists "public read work_creators of published works" on work_creators;
create policy "public read work_creators of published works" on work_creators
  for select using (
    exists (
      select 1 from works w
      where w.id = work_creators.work_id
        and w.status = 'published'
        and w.published_at <= now()
    )
  );

drop policy if exists "public read work_terms of published works" on work_terms;
create policy "public read work_terms of published works" on work_terms
  for select using (
    exists (
      select 1 from works w
      where w.id = work_terms.work_id
        and w.status = 'published'
        and w.published_at <= now()
    )
  );

-- Writes are intentionally NOT opened to the anon role. Use the
-- Supabase dashboard, a service-role key, or a server-side
-- function/edge function to publish content.
