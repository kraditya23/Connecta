-- ============================================================
-- Connecta – initial Supabase schema
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- ── Tables ──────────────────────────────────────────────────

create table public.profiles (
  id              uuid primary key references auth.users(id) on delete cascade,
  username        text not null unique,
  name            text,
  profile_pic_url text,
  cover_pic_url   text,
  job_title       text,
  organisation    text,
  location        text,
  address         text,
  phone_numbers   text[]  not null default '{}',
  emails          text[]  not null default '{}',
  link_section_header text,
  links_text      text[]  not null default '{}',
  link_url        text[]  not null default '{}',
  about_me        text,
  social_names    text[]  not null default '{}',
  social_url      text[]  not null default '{}',
  social_icons    text[]  not null default '{}',
  scheduling      text,
  settings        jsonb   not null default '{}',
  created_at      timestamptz not null default now()
);

create table public.connections (
  owner_id      uuid not null references public.profiles(id) on delete cascade,
  connection_id uuid not null references public.profiles(id) on delete cascade,
  since         timestamptz not null default now(),
  primary key (owner_id, connection_id)
);

create table public.support_feedback (
  id         bigserial primary key,
  uid        uuid,
  email      text,
  message    text not null,
  created_at timestamptz not null default now()
);

-- ── Row Level Security ──────────────────────────────────────

alter table public.profiles       enable row level security;
alter table public.connections     enable row level security;
alter table public.support_feedback enable row level security;

-- profiles: anyone can read; only the owner can write
create policy "profiles_public_read"   on public.profiles for select using (true);
create policy "profiles_self_insert"   on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_self_update"   on public.profiles for update using (auth.uid() = id);
create policy "profiles_self_delete"   on public.profiles for delete using (auth.uid() = id);

-- connections: users can only read their own rows; no direct insert/delete (use RPCs)
create policy "connections_self_read"  on public.connections for select using (auth.uid() = owner_id);

-- support_feedback: authenticated users can insert only
create policy "feedback_insert"        on public.support_feedback for insert with check (auth.uid() is not null);

-- ── Storage ─────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('profile-assets', 'profile-assets', true)
on conflict (id) do nothing;

create policy "profile_assets_public_read"
  on storage.objects for select
  using (bucket_id = 'profile-assets');

create policy "profile_assets_self_upload"
  on storage.objects for insert
  with check (
    bucket_id = 'profile-assets'
    and auth.uid() is not null
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "profile_assets_self_update"
  on storage.objects for update
  using (
    bucket_id = 'profile-assets'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "profile_assets_self_delete"
  on storage.objects for delete
  using (
    bucket_id = 'profile-assets'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ── RPCs ────────────────────────────────────────────────────

-- exchange_contacts: creates a mutual connection between the caller and target.
-- SECURITY DEFINER so the function can write to the connections table
-- even though direct inserts are blocked for regular users.
create or replace function exchange_contacts(target_username text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller_id  uuid := auth.uid();
  target_id  uuid;
begin
  if caller_id is null then
    raise exception 'Not authenticated';
  end if;

  select id into target_id from profiles where username = target_username;

  if target_id is null then
    raise exception 'User % not found', target_username;
  end if;

  if caller_id = target_id then
    raise exception 'Cannot connect to yourself';
  end if;

  insert into connections (owner_id, connection_id)
  values (caller_id, target_id)
  on conflict do nothing;

  insert into connections (owner_id, connection_id)
  values (target_id, caller_id)
  on conflict do nothing;
end;
$$;

-- delete_connection: removes the mutual connection between caller and target.
create or replace function delete_connection(target_username text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller_id  uuid := auth.uid();
  target_id  uuid;
begin
  if caller_id is null then
    raise exception 'Not authenticated';
  end if;

  select id into target_id from profiles where username = target_username;

  if target_id is null then
    raise exception 'User % not found', target_username;
  end if;

  delete from connections where owner_id = caller_id and connection_id = target_id;
  delete from connections where owner_id = target_id and connection_id = caller_id;
end;
$$;

-- Restrict RPC execution to authenticated users only
revoke execute on function exchange_contacts(text) from public, anon;
grant  execute on function exchange_contacts(text) to authenticated;

revoke execute on function delete_connection(text) from public, anon;
grant  execute on function delete_connection(text) to authenticated;
