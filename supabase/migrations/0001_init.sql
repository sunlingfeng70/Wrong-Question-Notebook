-- =====================================================================
-- Wrong Question Notebook — initial schema
-- Derived from the application code (lib/types.ts, lib/schemas.ts,
-- lib/constants.ts, app/api/*). There were no upstream migration files.
-- =====================================================================

-- ---------- Extensions ----------
create extension if not exists "pgcrypto";
create extension if not exists "pg_trgm";
create extension if not exists "pg_cron";

-- ---------- Enums ----------
do $$ begin
  create type public.problem_type as enum ('mcq', 'short', 'extended');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.problem_status as enum ('wrong', 'needs_review', 'mastered');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.sharing_level as enum ('private', 'limited', 'public');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.user_role as enum ('user', 'moderator', 'admin', 'super_admin');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.gender as enum ('male', 'female', 'other', 'prefer_not_to_say');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.session_type as enum ('normal', 'spaced_repetition', 'insights_review');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.qr_session_status as enum ('pending', 'uploaded', 'consumed', 'expired');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.digest_status as enum ('generating', 'completed', 'failed');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.report_status as enum ('pending', 'resolved', 'dismissed');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.error_broad_category as enum (
    'conceptual_misunderstanding', 'procedural_error', 'knowledge_gap',
    'misread_question', 'careless_mistake', 'time_pressure', 'incomplete_answer'
  );
exception when duplicate_object then null; end $$;

-- =====================================================================
-- Core tables
-- =====================================================================

create table if not exists public.user_profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text unique,
  first_name text,
  last_name text,
  date_of_birth date,
  gender public.gender,
  region text,
  timezone text not null default 'UTC',
  avatar_url text,
  bio text,
  user_role public.user_role not null default 'user',
  is_active boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  color text,
  icon text,
  created_at timestamptz not null default now()
);
create index if not exists subjects_user_id_idx on public.subjects (user_id);

create table if not exists public.tags (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  subject_id uuid not null references public.subjects (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  unique (user_id, subject_id, name)
);
create index if not exists tags_subject_id_idx on public.tags (subject_id);

create table if not exists public.problems (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  subject_id uuid not null references public.subjects (id) on delete cascade,
  title text not null,
  content text,
  problem_type public.problem_type not null,
  correct_answer text,
  answer_config jsonb,
  auto_mark boolean not null default false,
  status public.problem_status not null default 'needs_review',
  assets jsonb not null default '[]'::jsonb,
  solution_assets jsonb not null default '[]'::jsonb,
  solution_text text,
  last_reviewed_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists problems_user_id_idx on public.problems (user_id);
create index if not exists problems_subject_id_idx on public.problems (subject_id);
create index if not exists problems_status_idx on public.problems (status);

create table if not exists public.problem_tag (
  user_id uuid not null references auth.users (id) on delete cascade,
  problem_id uuid not null references public.problems (id) on delete cascade,
  tag_id uuid not null references public.tags (id) on delete cascade,
  primary key (problem_id, tag_id)
);
create index if not exists problem_tag_user_id_idx on public.problem_tag (user_id);

create table if not exists public.attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  problem_id uuid not null references public.problems (id) on delete cascade,
  submitted_answer jsonb,
  is_correct boolean,
  cause text,
  is_self_assessed boolean not null default false,
  confidence integer check (confidence between 1 and 5),
  reflection_notes text,
  selected_status public.problem_status,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists attempts_user_id_idx on public.attempts (user_id);
create index if not exists attempts_problem_id_idx on public.attempts (problem_id);

create table if not exists public.review_schedule (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  problem_id uuid not null references public.problems (id) on delete cascade,
  next_review_at timestamptz not null default now(),
  interval_days integer not null default 1,
  ease_factor double precision not null default 2.5,
  repetition_number integer not null default 0,
  last_reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, problem_id)
);
create index if not exists review_schedule_due_idx on public.review_schedule (user_id, next_review_at);

create table if not exists public.review_session_state (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  problem_set_id uuid,
  session_type public.session_type not null default 'normal',
  subject_id uuid,
  started_at timestamptz not null default now(),
  last_activity_at timestamptz not null default now(),
  is_active boolean not null default true,
  session_state jsonb not null default '{}'::jsonb
);
create index if not exists review_session_state_user_idx on public.review_session_state (user_id, is_active);

create table if not exists public.review_session_results (
  id uuid primary key default gen_random_uuid(),
  session_state_id uuid not null references public.review_session_state (id) on delete cascade,
  problem_id uuid not null references public.problems (id) on delete cascade,
  completed_at timestamptz not null default now(),
  was_correct boolean,
  was_skipped boolean not null default false
);
create index if not exists review_session_results_state_idx on public.review_session_results (session_state_id);

-- =====================================================================
-- Problem sets + social
-- =====================================================================

create table if not exists public.problem_sets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  subject_id uuid not null references public.subjects (id) on delete cascade,
  name text not null,
  description text,
  sharing_level public.sharing_level not null default 'private',
  is_smart boolean not null default false,
  filter_config jsonb,
  session_config jsonb,
  allow_copying boolean not null default true,
  is_listed boolean not null default false,
  discovery_subject text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists problem_sets_user_id_idx on public.problem_sets (user_id);

create table if not exists public.problem_set_shares (
  id uuid primary key default gen_random_uuid(),
  problem_set_id uuid not null references public.problem_sets (id) on delete cascade,
  shared_with_email text not null,
  shared_by_user_id uuid references auth.users (id) on delete set null,
  unique (problem_set_id, shared_with_email)
);

create table if not exists public.problem_set_problems (
  id uuid primary key default gen_random_uuid(),
  problem_set_id uuid not null references public.problem_sets (id) on delete cascade,
  problem_id uuid not null references public.problems (id) on delete cascade,
  user_id uuid references auth.users (id) on delete cascade,
  added_at timestamptz not null default now(),
  unique (problem_set_id, problem_id)
);
create index if not exists problem_set_problems_problem_idx on public.problem_set_problems (problem_id);

create table if not exists public.problem_set_stats (
  problem_set_id uuid primary key references public.problem_sets (id) on delete cascade,
  view_count integer not null default 0,
  unique_view_count integer not null default 0,
  like_count integer not null default 0,
  copy_count integer not null default 0,
  problem_count integer not null default 0,
  ranking_score double precision not null default 0
);

create table if not exists public.problem_set_likes (
  problem_set_id uuid not null references public.problem_sets (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (problem_set_id, user_id)
);

create table if not exists public.problem_set_favourites (
  problem_set_id uuid not null references public.problem_sets (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (problem_set_id, user_id)
);

create table if not exists public.problem_set_views (
  id uuid primary key default gen_random_uuid(),
  problem_set_id uuid not null references public.problem_sets (id) on delete cascade,
  viewer_hash text not null,
  viewed_at timestamptz not null default now()
);
create index if not exists problem_set_views_dedup_idx on public.problem_set_views (problem_set_id, viewer_hash, viewed_at);

create table if not exists public.problem_set_reports (
  id uuid primary key default gen_random_uuid(),
  problem_set_id uuid not null references public.problem_sets (id) on delete cascade,
  reporter_user_id uuid references auth.users (id) on delete set null,
  reason text not null,
  details text,
  status public.report_status not null default 'pending',
  created_at timestamptz not null default now()
);

-- =====================================================================
-- Admin, activity, quotas
-- =====================================================================

create table if not exists public.user_activity_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  action text not null,
  resource_type text,
  resource_id uuid,
  details jsonb,
  ip_address text,
  user_agent text,
  created_at timestamptz not null default now()
);
create index if not exists user_activity_log_user_idx on public.user_activity_log (user_id, created_at desc);

create table if not exists public.admin_settings (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  value jsonb not null default '{}'::jsonb,
  description text,
  updated_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.usage_quotas (
  user_id uuid not null references auth.users (id) on delete cascade,
  resource_type text not null,
  period_start date not null,
  usage_count integer not null default 0,
  primary key (user_id, resource_type, period_start)
);

create table if not exists public.user_quota_overrides (
  user_id uuid not null references auth.users (id) on delete cascade,
  resource_type text not null,
  daily_limit integer not null,
  primary key (user_id, resource_type)
);

create table if not exists public.content_limit_overrides (
  user_id uuid not null references auth.users (id) on delete cascade,
  resource_type text not null,
  limit_value numeric not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, resource_type)
);

-- =====================================================================
-- QR upload, insights
-- =====================================================================

create table if not exists public.qr_upload_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  token_hash text not null unique,
  status public.qr_session_status not null default 'pending',
  file_path text,
  mime_type text,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  uploaded_at timestamptz,
  consumed_at timestamptz
);
create index if not exists qr_upload_sessions_user_idx on public.qr_upload_sessions (user_id, created_at desc);

create table if not exists public.error_categorisations (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null unique references public.attempts (id) on delete cascade,
  problem_id uuid not null references public.problems (id) on delete cascade,
  subject_id uuid not null references public.subjects (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  broad_category public.error_broad_category not null,
  granular_tag text not null,
  topic_label text not null,
  topic_label_normalised text not null,
  ai_confidence double precision not null default 0,
  ai_reasoning text,
  is_user_override boolean not null default false,
  original_broad_category public.error_broad_category,
  original_granular_tag text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists error_categorisations_user_idx on public.error_categorisations (user_id, subject_id);

create table if not exists public.insight_digests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  generated_at timestamptz not null default now(),
  status public.digest_status not null default 'generating',
  headline text not null default '',
  error_pattern_summary text not null default '',
  subject_error_patterns jsonb,
  subject_health jsonb,
  weak_spots jsonb,
  topic_clusters jsonb,
  progress_narratives jsonb,
  raw_aggregation_data jsonb,
  digest_tier text
);
create index if not exists insight_digests_user_idx on public.insight_digests (user_id, generated_at desc);

-- =====================================================================
-- updated_at triggers
-- =====================================================================

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists set_updated_at_problems on public.problems;
create trigger set_updated_at_problems before update on public.problems
  for each row execute function public.set_updated_at();
drop trigger if exists set_updated_at_attempts on public.attempts;
create trigger set_updated_at_attempts before update on public.attempts
  for each row execute function public.set_updated_at();
drop trigger if exists set_updated_at_problem_sets on public.problem_sets;
create trigger set_updated_at_problem_sets before update on public.problem_sets
  for each row execute function public.set_updated_at();
drop trigger if exists set_updated_at_review_schedule on public.review_schedule;
create trigger set_updated_at_review_schedule before update on public.review_schedule
  for each row execute function public.set_updated_at();
drop trigger if exists set_updated_at_error_categorisations on public.error_categorisations;
create trigger set_updated_at_error_categorisations before update on public.error_categorisations
  for each row execute function public.set_updated_at();
drop trigger if exists set_updated_at_user_profiles on public.user_profiles;
create trigger set_updated_at_user_profiles before update on public.user_profiles
  for each row execute function public.set_updated_at();
drop trigger if exists set_updated_at_admin_settings on public.admin_settings;
create trigger set_updated_at_admin_settings before update on public.admin_settings
  for each row execute function public.set_updated_at();

-- =====================================================================
-- New user → profile bootstrap
-- =====================================================================

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  base text;
  uname text;
  n int := 0;
begin
  base := nullif(new.raw_user_meta_data->>'username', '');
  if base is null or base = '' then
    base := split_part(coalesce(new.email, ''), '@', 1);
  end if;
  base := regexp_replace(base, '[^a-zA-Z0-9_-]', '', 'g');
  if base = '' then base := 'user'; end if;
  base := left(base, 30);
  uname := base;
  -- Keep trying suffixes until username is unique
  while exists (select 1 from public.user_profiles where username = uname) loop
    n := n + 1;
    uname := left(base, 30 - length(n::text)) || n::text;
  end loop;
  insert into public.user_profiles (id, username)
  values (new.id, uname)
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
-- Problem set stats bootstrap + count maintenance
-- =====================================================================

create or replace function public.ensure_problem_set_stats()
returns trigger language plpgsql as $$
begin
  insert into public.problem_set_stats (problem_set_id)
  values (new.id)
  on conflict (problem_set_id) do nothing;
  return new;
end $$;

drop trigger if exists ensure_problem_set_stats_trigger on public.problem_sets;
create trigger ensure_problem_set_stats_trigger
  after insert on public.problem_sets
  for each row execute function public.ensure_problem_set_stats();

create or replace function public.recalc_problem_count()
returns trigger language plpgsql as $$
declare
  pid uuid;
begin
  if tg_op = 'DELETE' then
    pid = old.problem_set_id;
    -- Parent set may already be gone (cascade delete of problem_sets): skip.
    if not exists (select 1 from public.problem_sets where id = pid) then
      return old;
    end if;
  else
    pid = new.problem_set_id;
  end if;
  insert into public.problem_set_stats (problem_set_id)
  values (pid) on conflict (problem_set_id) do nothing;
  update public.problem_set_stats s
  set problem_count = (
    select count(*) from public.problem_set_problems p where p.problem_set_id = pid
  )
  where s.problem_set_id = pid;
  return coalesce(new, old);
end $$;

drop trigger if exists recalc_problem_count_trigger on public.problem_set_problems;
create trigger recalc_problem_count_trigger
  after insert or delete on public.problem_set_problems
  for each row execute function public.recalc_problem_count();

-- =====================================================================
-- RPC: social engagement
-- =====================================================================

create or replace function public.record_problem_set_view(
  p_problem_set_id uuid,
  p_viewer_hash text,
  p_user_id uuid default null
)
returns void language plpgsql as $$
declare
  v_recent timestamptz;
begin
  -- Bounce + dedup window: only count a view from this viewer once per 15 min
  select max(viewed_at) into v_recent
  from public.problem_set_views
  where problem_set_id = p_problem_set_id and viewer_hash = p_viewer_hash
    and viewed_at > now() - interval '15 minutes';

  if v_recent is null then
    insert into public.problem_set_views (problem_set_id, viewer_hash)
    values (p_problem_set_id, p_viewer_hash);
    insert into public.problem_set_stats (problem_set_id)
    values (p_problem_set_id) on conflict (problem_set_id) do nothing;
    update public.problem_set_stats
    set view_count = view_count + 1,
        unique_view_count = unique_view_count + 1
    where problem_set_id = p_problem_set_id;
  end if;
end $$;

create or replace function public.toggle_problem_set_like(
  p_problem_set_id uuid,
  p_user_id uuid
)
returns table (liked boolean, like_count bigint)
language plpgsql as $$
declare
  v_liked boolean;
begin
  select exists (
    select 1 from public.problem_set_likes
    where problem_set_id = p_problem_set_id and user_id = p_user_id
  ) into v_liked;

  if v_liked then
    delete from public.problem_set_likes
    where problem_set_id = p_problem_set_id and user_id = p_user_id;
    liked := false;
  else
    insert into public.problem_set_likes (problem_set_id, user_id)
    values (p_problem_set_id, p_user_id)
    on conflict do nothing;
    liked := true;
  end if;

  insert into public.problem_set_stats (problem_set_id)
  values (p_problem_set_id) on conflict (problem_set_id) do nothing;
  update public.problem_set_stats
  set like_count = (select count(*) from public.problem_set_likes where problem_set_id = p_problem_set_id)
  where problem_set_id = p_problem_set_id;

  return query
  select liked,
         (select like_count::bigint from public.problem_set_stats where problem_set_id = p_problem_set_id);
end $$;

create or replace function public.record_problem_set_copy(
  p_problem_set_id uuid,
  p_user_id uuid default null
)
returns void language plpgsql as $$
begin
  insert into public.problem_set_stats (problem_set_id)
  values (p_problem_set_id) on conflict (problem_set_id) do nothing;
  update public.problem_set_stats
  set copy_count = copy_count + 1
  where problem_set_id = p_problem_set_id;
end $$;

-- =====================================================================
-- RPC: file ownership / access
-- =====================================================================

create or replace function public.find_problem_by_asset(p_path text)
returns text language sql stable as $$
  select id::text from public.problems
  where assets @> jsonb_build_array(jsonb_build_object('path', p_path))
     or solution_assets @> jsonb_build_array(jsonb_build_object('path', p_path))
  limit 1;
$$;

create or replace function public.user_owns_problem_with_asset(p_path text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.problems
    where (assets @> jsonb_build_array(jsonb_build_object('path', p_path))
       or solution_assets @> jsonb_build_array(jsonb_build_object('path', p_path)))
      and user_id = auth.uid()
  );
$$;

create or replace function public.can_view_problem(p_problem_id uuid)
returns boolean language plpgsql stable security definer set search_path = public as $$
declare
  pid uuid;
  owner_id uuid;
  sharing public.sharing_level;
begin
  select id into pid from public.problems where id = p_problem_id;
  if pid is null then return false; end if;

  -- Owner can always view
  select user_id into owner_id from public.problems where id = p_problem_id;
  if auth.uid() = owner_id then return true; end if;

  -- Visible if the problem belongs to a public problem set
  select distinct ps.sharing_level into sharing
  from public.problem_set_problems psp
  join public.problem_sets ps on ps.id = psp.problem_set_id
  where psp.problem_id = p_problem_id and ps.sharing_level = 'public'
  limit 1;

  return sharing = 'public';
end $$;

-- =====================================================================
-- RPC: quota / storage
-- =====================================================================

create or replace function public.get_user_storage_bytes(p_user_id uuid)
returns bigint language plpgsql stable security definer set search_path = public as $$
declare
  total bigint;
begin
  select coalesce(sum((metadata->>'size')::bigint), 0)
  into total
  from storage.objects
  where owner_id = p_user_id::text
    and bucket_id in ('problem-uploads', 'avatars');
  return total;
end $$;

create or replace function public.check_and_increment_quota(
  p_user_id uuid,
  p_resource_type text,
  p_default_limit integer,
  p_user_tz text default 'UTC'
)
returns jsonb language plpgsql as $$
declare
  limit_val integer := p_default_limit;
  used integer;
  today date := (now() at time zone coalesce(p_user_tz, 'UTC'))::date;
  out_json jsonb;
begin
  select daily_limit into limit_val
  from public.user_quota_overrides
  where user_id = p_user_id and resource_type = p_resource_type;
  if limit_val is null then limit_val := p_default_limit; end if;

  insert into public.usage_quotas (user_id, resource_type, period_start, usage_count)
  values (p_user_id, p_resource_type, today, 0)
  on conflict (user_id, resource_type, period_start) do nothing;

  update public.usage_quotas
  set usage_count = usage_count + 1
  where user_id = p_user_id and resource_type = p_resource_type and period_start = today;

  select usage_count into used
  from public.usage_quotas
  where user_id = p_user_id and resource_type = p_resource_type and period_start = today;

  out_json := jsonb_build_object(
    'allowed', used <= limit_val,
    'current_usage', used,
    'daily_limit', limit_val,
    'remaining', greatest(limit_val - used, 0)
  );
  return out_json;
end $$;

-- =====================================================================
-- RPC: activity log
-- =====================================================================

create or replace function public.log_user_activity(
  p_action text,
  p_resource_type text default null,
  p_resource_id uuid default null,
  p_details jsonb default null
)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into public.user_activity_log (user_id, action, resource_type, resource_id, details)
  values (auth.uid(), p_action, p_resource_type, p_resource_id, p_details);
end $$;

-- =====================================================================
-- RPC: statistics dashboard
-- =====================================================================

create or replace function public.get_user_statistics(p_user_id uuid)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  total_problems int; mastered int; needs_review int; wrong int;
begin
  select count(*) into total_problems from public.problems where user_id = p_user_id;
  select count(*) into mastered from public.problems where user_id = p_user_id and status = 'mastered';
  select count(*) into needs_review from public.problems where user_id = p_user_id and status = 'needs_review';
  select count(*) into wrong from public.problems where user_id = p_user_id and status = 'wrong';
  return jsonb_build_object(
    'total_problems', total_problems,
    'mastered_count', mastered,
    'needs_review_count', needs_review,
    'wrong_count', wrong,
    'mastery_rate', case when total_problems = 0 then 0 else round(mastered::numeric / total_problems * 100, 1) end
  );
end $$;

create or replace function public.get_study_streaks(p_user_id uuid, p_user_tz text default 'UTC')
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  cur int := 0; longest int := 0; run int := 0;
  d date; prev date := null;
begin
  for d in
    select distinct ((created_at at time zone coalesce(p_user_tz,'UTC'))::date)
    from public.user_activity_log where user_id = p_user_id
    order by 1 desc
  loop
    if prev is null then
      run := 1; cur := 1;
    elsif d = prev - 1 then
      run := run + 1; cur := cur + 1;
    elsif d < prev - 1 then
      run := 1;
    end if;
    longest := greatest(longest, run);
    prev := d;
  end loop;
  return jsonb_build_object('current_streak', cur, 'longest_streak', longest);
end $$;

create or replace function public.get_session_statistics(p_user_id uuid)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  total_sessions int; total_ms double precision; total_problems int;
begin
  select count(*), coalesce(avg((session_state->>'elapsed_ms')::double precision), 0),
         coalesce(sum(jsonb_array_length(coalesce(session_state->'completed_problem_ids', '[]'::jsonb))), 0)
  into total_sessions, total_ms, total_problems
  from public.review_session_state
  where user_id = p_user_id;
  return jsonb_build_object(
    'total_sessions', total_sessions,
    'avg_duration_ms', round(total_ms),
    'avg_problems_per_session', case when total_sessions = 0 then 0 else round(total_problems::numeric / total_sessions, 1) end,
    'total_review_time_ms', round(total_ms * total_sessions)
  );
end $$;

create or replace function public.get_subject_breakdown(p_user_id uuid)
returns table (
  subject_id uuid, subject_name text, total bigint,
  mastered bigint, needs_review bigint, wrong bigint, mastery_pct numeric
) language plpgsql stable security definer set search_path = public as $$
begin
  return query
  select s.id, s.name,
         count(p.id)::bigint,
         count(p.id) filter (where p.status = 'mastered')::bigint,
         count(p.id) filter (where p.status = 'needs_review')::bigint,
         count(p.id) filter (where p.status = 'wrong')::bigint,
         case when count(p.id) = 0 then 0
              else round(count(p.id) filter (where p.status = 'mastered')::numeric / count(p.id) * 100, 1) end
  from public.subjects s
  left join public.problems p on p.subject_id = s.id and p.user_id = p_user_id
  where s.user_id = p_user_id
  group by s.id, s.name
  order by s.name;
end $$;

create or replace function public.get_weekly_progress(p_user_id uuid, p_user_tz text default 'UTC')
returns table (week_start date, cumulative_mastered bigint)
language plpgsql stable security definer set search_path = public as $$
begin
  return query
  select date_trunc('week', last_reviewed_date)::date as week_start,
         count(*) over (order by date_trunc('week', last_reviewed_date)) as cumulative_mastered
  from (
    select distinct on (p.id) p.id, coalesce(p.last_reviewed_date, p.created_at::date) as last_reviewed_date
    from public.problems p
    where p.user_id = p_user_id and p.status = 'mastered'
  ) m
  order by week_start;
end $$;

create or replace function public.get_activity_heatmap(p_user_id uuid, p_user_tz text default 'UTC')
returns table (activity_date date, activity_count bigint)
language plpgsql stable security definer set search_path = public as $$
begin
  return query
  select ((created_at at time zone coalesce(p_user_tz,'UTC'))::date) as activity_date,
         count(*)::bigint as activity_count
  from public.user_activity_log
  where user_id = p_user_id
    and created_at > now() - interval '365 days'
  group by 1
  order by 1;
end $$;

create or replace function public.get_recent_study_activity(p_user_id uuid)
returns table (
  problem_id uuid, problem_title text, subject_name text,
  old_status text, new_status text, changed_at timestamptz
) language plpgsql stable security definer set search_path = public as $$
begin
  return query
  select a.problem_id, p.title, s.name,
         null::text,
         a.selected_status::text,
         a.created_at
  from public.attempts a
  join public.problems p on p.id = a.problem_id
  join public.subjects s on s.id = p.subject_id
  where a.user_id = p_user_id and a.selected_status is not null
  order by a.created_at desc
  limit 20;
end $$;

-- =====================================================================
-- RPC: insights / digest generation
-- =====================================================================

create or replace function public.get_activity_summary(p_user_id uuid)
returns table (
  total_problems bigint,
  total_attempts bigint,
  total_subjects bigint,
  problems_with_errors bigint
) language sql stable security definer set search_path = public as $$
  select
    (select count(*) from public.problems where user_id = p_user_id),
    (select count(*) from public.attempts where user_id = p_user_id),
    (select count(*) from public.subjects where user_id = p_user_id),
    (select count(distinct ec.problem_id) from public.error_categorisations ec where ec.user_id = p_user_id);
$$;

create or replace function public.get_error_aggregation_data(p_user_id uuid)
returns table (
  categorisation_id uuid, attempt_id uuid, problem_id uuid, subject_id uuid,
  subject_name text, broad_category public.error_broad_category,
  granular_tag text, topic_label text, topic_label_normalised text,
  ai_confidence double precision, is_user_override boolean,
  problem_status text, problem_title text,
  attempt_created_at timestamptz, categorisation_created_at timestamptz,
  attempt_selected_status text
) language sql stable security definer set search_path = public as $$
  select
    ec.id, ec.attempt_id, ec.problem_id, ec.subject_id,
    s.name, ec.broad_category, ec.granular_tag, ec.topic_label,
    ec.topic_label_normalised, ec.ai_confidence, ec.is_user_override,
    p.status::text, p.title,
    a.created_at, ec.created_at,
    a.selected_status::text
  from public.error_categorisations ec
  join public.attempts a on a.id = ec.attempt_id
  join public.problems p on p.id = ec.problem_id
  join public.subjects s on s.id = ec.subject_id
  where ec.user_id = p_user_id
  order by ec.created_at desc;
$$;

create or replace function public.get_uncategorised_attempts(
  p_user_id uuid,
  p_limit integer default 20
)
returns table (
  attempt_id uuid, problem_id uuid, subject_id uuid,
  submitted_answer jsonb, is_correct boolean, cause text,
  reflection_notes text, selected_status text,
  attempt_created_at timestamptz, problem_title text,
  problem_content text, problem_type text, correct_answer text, subject_name text
) language sql stable security definer set search_path = public as $$
  select
    a.id, a.problem_id, p.subject_id,
    a.submitted_answer, a.is_correct, a.cause,
    a.reflection_notes, a.selected_status::text,
    a.created_at, p.title, p.content, p.problem_type::text, p.correct_answer,
    s.name
  from public.attempts a
  join public.problems p on p.id = a.problem_id
  join public.subjects s on s.id = p.subject_id
  where a.user_id = p_user_id
    and (a.selected_status = 'wrong' or a.selected_status = 'needs_review')
    and not exists (
      select 1 from public.error_categorisations ec where ec.attempt_id = a.id
    )
  order by a.created_at desc
  limit p_limit;
$$;

create or replace function public.get_unreferenced_asset_paths(
  p_paths text[],
  p_exclude_problem_id uuid
)
returns text[] language sql stable security definer set search_path = public as $$
  select array(
    select pth
    from unnest(p_paths) as pth
    where not exists (
      select 1 from public.problems
      where id <> p_exclude_problem_id
        and (assets @> jsonb_build_array(jsonb_build_object('path', pth))
          or solution_assets @> jsonb_build_array(jsonb_build_object('path', pth)))
    )
  );
$$;

-- =====================================================================
-- RPC: subjects with metadata
-- =====================================================================

create or replace function public.get_subjects_with_metadata()
returns table (
  id uuid, name text, color text, icon text, created_at timestamptz,
  problem_count bigint, last_activity timestamptz, due_count bigint
) language plpgsql stable security definer set search_path = public as $$
begin
  return query
  select s.id, s.name, s.color, s.icon, s.created_at,
         count(p.id)::bigint,
         max(coalesce(p.updated_at, p.created_at))::timestamptz,
         count(rs.id) filter (where rs.next_review_at <= now() and p.status <> 'mastered')::bigint
  from public.subjects s
  left join public.problems p on p.subject_id = s.id
  left join public.review_schedule rs on rs.problem_id = p.id
  where s.user_id = auth.uid()
  group by s.id, s.name, s.color, s.icon, s.created_at
  order by s.created_at asc;
end $$;

-- =====================================================================
-- RPC: spaced repetition
-- =====================================================================

create or replace function public.get_due_problems_for_subject(
  p_subject_id uuid,
  p_limit integer default 20
)
returns table (id uuid, status public.problem_status)
language sql stable security definer set search_path = public as $$
  select p.id, p.status
  from public.problems p
  join public.review_schedule rs on rs.problem_id = p.id and rs.user_id = p.user_id
  where p.subject_id = p_subject_id
    and p.user_id = auth.uid()
    and p.status <> 'mastered'
    and rs.next_review_at <= now()
  order by rs.next_review_at asc
  limit p_limit;
$$;

-- =====================================================================
-- Discovery: table + refresh + cron
-- =====================================================================

-- Flattened, denormalised table refreshed by pg_cron. Kept as a real table
-- (not a view) so PostgREST can do native textSearch + keyset ordering on it.
create table if not exists public.discoverable_problem_sets (
  id uuid primary key,
  user_id uuid,
  name text,
  description text,
  is_smart boolean,
  discovery_subject text,
  created_at timestamptz,
  problem_count bigint,
  view_count bigint,
  unique_view_count bigint,
  like_count bigint,
  copy_count bigint,
  ranking_score double precision,
  fts tsvector
);
create index if not exists discoverable_fts_idx on public.discoverable_problem_sets using gin (fts);
create index if not exists discoverable_ranking_idx on public.discoverable_problem_sets (ranking_score desc, id);
create index if not exists discoverable_created_idx on public.discoverable_problem_sets (created_at desc, id);
create index if not exists discoverable_liked_idx on public.discoverable_problem_sets (like_count desc, id);
create index if not exists discoverable_copied_idx on public.discoverable_problem_sets (copy_count desc, id);

create or replace function public.refresh_discoverable_problem_sets()
returns void language plpgsql security definer set search_path = public as $$
begin
  delete from public.discoverable_problem_sets;

  insert into public.discoverable_problem_sets (
    id, user_id, name, description, is_smart, discovery_subject,
    created_at, problem_count, view_count, unique_view_count,
    like_count, copy_count, ranking_score, fts
  )
  select
    ps.id,
    ps.user_id,
    ps.name,
    ps.description,
    ps.is_smart,
    coalesce(ps.discovery_subject, 'Other'),
    ps.created_at,
    coalesce(st.problem_count, 0),
    coalesce(st.view_count, 0),
    coalesce(st.unique_view_count, 0),
    coalesce(st.like_count, 0),
    coalesce(st.copy_count, 0),
    -- Quality-biased ranking: likes weight heaviest, then copies, then views
    coalesce(st.like_count, 0) * 3.0
      + coalesce(st.copy_count, 0) * 2.0
      + coalesce(st.unique_view_count, 0) * 0.2
      + coalesce(st.problem_count, 0) * 0.1
      - extract(epoch from (now() - ps.created_at)) / 86400.0 * 0.02,
    (
      setweight(to_tsvector('simple', coalesce(ps.name, '')), 'A') ||
      setweight(to_tsvector('simple', coalesce(ps.description, '')), 'B') ||
      setweight(to_tsvector('simple', coalesce(ps.discovery_subject, '')), 'B')
    )
  from public.problem_sets ps
  left join public.problem_set_stats st on st.problem_set_id = ps.id
  where ps.sharing_level = 'public' and ps.is_listed = true
  order by ps.created_at desc;
end $$;

create or replace function public.get_discovery_subject_counts()
returns table (name text, count bigint)
language sql stable as $$
  select discovery_subject, count(*) from public.discoverable_problem_sets
  group by discovery_subject order by count desc;
$$;

-- =====================================================================
-- RLS
-- =====================================================================

alter table public.user_profiles enable row level security;
alter table public.subjects enable row level security;
alter table public.tags enable row level security;
alter table public.problems enable row level security;
alter table public.problem_tag enable row level security;
alter table public.attempts enable row level security;
alter table public.review_schedule enable row level security;
alter table public.review_session_state enable row level security;
alter table public.review_session_results enable row level security;
alter table public.problem_sets enable row level security;
alter table public.problem_set_shares enable row level security;
alter table public.problem_set_problems enable row level security;
alter table public.problem_set_stats enable row level security;
alter table public.problem_set_likes enable row level security;
alter table public.problem_set_favourites enable row level security;
alter table public.problem_set_views enable row level security;
alter table public.problem_set_reports enable row level security;
alter table public.user_activity_log enable row level security;
alter table public.usage_quotas enable row level security;
alter table public.user_quota_overrides enable row level security;
alter table public.content_limit_overrides enable row level security;
alter table public.qr_upload_sessions enable row level security;
alter table public.error_categorisations enable row level security;
alter table public.insight_digests enable row level security;

-- Owner-scoped access on personal tables
drop policy if exists "own rows" on public.user_profiles;
create policy "own rows" on public.user_profiles  for select using (auth.uid() = id);
drop policy if exists "own profile update" on public.user_profiles;
create policy "own profile update" on public.user_profiles  for update using (auth.uid() = id);
drop policy if exists "own subjects" on public.subjects;
create policy "own subjects" on public.subjects  for all using (auth.uid() = user_id);
drop policy if exists "own tags" on public.tags;
create policy "own tags" on public.tags  for all using (auth.uid() = user_id);
drop policy if exists "own problems" on public.problems;
create policy "own problems" on public.problems  for all using (auth.uid() = user_id);
drop policy if exists "own problem_tag" on public.problem_tag;
create policy "own problem_tag" on public.problem_tag  for all using (auth.uid() = user_id);
drop policy if exists "own attempts" on public.attempts;
create policy "own attempts" on public.attempts  for all using (auth.uid() = user_id);
drop policy if exists "own review_schedule" on public.review_schedule;
create policy "own review_schedule" on public.review_schedule  for all using (auth.uid() = user_id);
drop policy if exists "own review_session_state" on public.review_session_state;
create policy "own review_session_state" on public.review_session_state  for all using (auth.uid() = user_id);
drop policy if exists "own review_session_results" on public.review_session_results;
create policy "own review_session_results" on public.review_session_results  for all using (exists (
    select 1 from public.review_session_state s
    where s.id = review_session_results.session_state_id and s.user_id = auth.uid()));
drop policy if exists "own problem_sets" on public.problem_sets;
create policy "own problem_sets" on public.problem_sets  for all using (auth.uid() = user_id);
drop policy if exists "own problem_set_problems" on public.problem_set_problems;
create policy "own problem_set_problems" on public.problem_set_problems  for all using (auth.uid() = user_id);
drop policy if exists "own activity log" on public.user_activity_log;
create policy "own activity log" on public.user_activity_log  for all using (auth.uid() = user_id);
drop policy if exists "own usage_quotas" on public.usage_quotas;
create policy "own usage_quotas" on public.usage_quotas  for all using (auth.uid() = user_id);
drop policy if exists "own qr_sessions" on public.qr_upload_sessions;
create policy "own qr_sessions" on public.qr_upload_sessions  for all using (auth.uid() = user_id);
drop policy if exists "own error_categorisations" on public.error_categorisations;
create policy "own error_categorisations" on public.error_categorisations  for all using (auth.uid() = user_id);
drop policy if exists "own insight_digests" on public.insight_digests;
create policy "own insight_digests" on public.insight_digests  for all using (auth.uid() = user_id);

-- Public/limited problem sets + social reads
drop policy if exists "read public sets" on public.problem_sets;
create policy "read public sets" on public.problem_sets  for select using (sharing_level = 'public' or auth.uid() = user_id);
drop policy if exists "read public set problems" on public.problem_set_problems;
create policy "read public set problems" on public.problem_set_problems  for select using (exists (
    select 1 from public.problem_sets ps
    where ps.id = problem_set_problems.problem_set_id
      and (ps.sharing_level = 'public' or ps.user_id = auth.uid())));
drop policy if exists "read set stats" on public.problem_set_stats;
create policy "read set stats" on public.problem_set_stats  for select using (true);
drop policy if exists "insert own set stats" on public.problem_set_stats;
create policy "insert own set stats" on public.problem_set_stats
  for insert with check (
    exists (select 1 from public.problem_sets ps
      where ps.id = problem_set_id and ps.user_id = auth.uid()));
drop policy if exists "update own set stats" on public.problem_set_stats;
create policy "update own set stats" on public.problem_set_stats
  for update using (
    exists (select 1 from public.problem_sets ps
      where ps.id = problem_set_id and ps.user_id = auth.uid()));
drop policy if exists "read likes" on public.problem_set_likes;
create policy "read likes" on public.problem_set_likes  for select using (true);
drop policy if exists "my likes" on public.problem_set_likes;
create policy "my likes" on public.problem_set_likes  for insert with check (auth.uid() = user_id);
drop policy if exists "read favourites" on public.problem_set_favourites;
create policy "read favourites" on public.problem_set_favourites  for select using (auth.uid() = user_id);
drop policy if exists "my favourites" on public.problem_set_favourites;
create policy "my favourites" on public.problem_set_favourites  for insert with check (auth.uid() = user_id);
drop policy if exists "report any set" on public.problem_set_reports;
create policy "report any set" on public.problem_set_reports  for insert with check (auth.uid() = reporter_user_id);
drop policy if exists "read profiles for discovery" on public.user_profiles;
create policy "read profiles for discovery" on public.user_profiles  for select using (true);

-- =====================================================================
-- Storage buckets
-- =====================================================================

insert into storage.buckets (id, name, public)
values ('problem-uploads', 'problem-uploads', false)
on conflict (id) do nothing;
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "problem-uploads owner all" on storage.objects;
create policy "problem-uploads owner all" on storage.objects  for all using (bucket_id = 'problem-uploads' and owner_id = auth.uid()::text)
  with check (bucket_id = 'problem-uploads' and owner_id = auth.uid()::text);
drop policy if exists "avatars public read" on storage.objects;
create policy "avatars public read" on storage.objects  for select using (bucket_id = 'avatars');
drop policy if exists "avatars owner all" on storage.objects;
create policy "avatars owner all" on storage.objects  for all using (bucket_id = 'avatars' and owner_id = auth.uid()::text)
  with check (bucket_id = 'avatars' and owner_id = auth.uid()::text);

-- =====================================================================
-- Seed: default admin settings (announcement etc.)
-- =====================================================================

insert into public.admin_settings (key, value, description) values
  ('site_announcement', '{"enabled": false, "message": "", "type": "info"}', 'Site-wide announcement banner')
on conflict (key) do nothing;

-- =====================================================================
-- Cron: refresh discovery every 5 minutes
-- =====================================================================

do $$
begin
  if not exists (select 1 from cron.job where jobname = 'refresh-discoverable-sets') then
    perform cron.schedule(
      'refresh-discoverable-sets',
      '*/5 * * * *',
      'select public.refresh_discoverable_problem_sets()'
    );
  end if;
end $$;
