-- EveryDay — rode no SQL Editor do Supabase (uma vez por projeto).

create or replace function public.random_invite_code()
returns text
language sql
volatile
set search_path = public
as $$
  select upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));
$$;

do $$ begin
  create type public.user_role as enum ('member', 'leader', 'pastor');
exception when duplicate_object then null;
end $$;

create table if not exists public.churches (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null,
  initials text not null,
  avatar_color int not null default 14260659,
  church_id uuid references public.churches (id) on delete set null,
  role public.user_role not null default 'member',
  created_at timestamptz not null default now()
);

alter table public.profiles add column if not exists yvp_id text;
create unique index if not exists profiles_yvp_id_uidx
  on public.profiles (yvp_id) where yvp_id is not null;

create table if not exists public.reading_plans (
  id uuid primary key default gen_random_uuid(),
  church_id uuid not null references public.churches (id) on delete cascade,
  title text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.plan_days (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.reading_plans (id) on delete cascade,
  day date not null,
  passage_label text not null,
  book text not null,
  start_chapter int not null,
  end_chapter int not null,
  unique (plan_id, day)
);

create table if not exists public.reading_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  church_id uuid not null references public.churches (id) on delete cascade,
  passage_label text not null,
  minutes int not null default 15,
  note text,
  kind text not null default 'progress',
  occurred_at timestamptz not null default now()
);

create table if not exists public.reactions (
  log_id uuid not null references public.reading_logs (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  primary key (log_id, user_id)
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  log_id uuid not null references public.reading_logs (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  church_id uuid not null references public.churches (id) on delete cascade,
  name text not null,
  plan_label text not null default 'Leitura da igreja',
  plan_id uuid references public.reading_plans (id) on delete set null,
  invite_code text not null unique,
  created_by uuid references public.profiles (id) on delete set null
);

create table if not exists public.group_members (
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  primary key (group_id, user_id)
);

create table if not exists public.bible_books (
  id text primary key,
  name text not null,
  testament text not null check (testament in ('old', 'new')),
  chapters int not null
);

create table if not exists public.book_progress (
  user_id uuid not null references public.profiles (id) on delete cascade,
  book_id text not null references public.bible_books (id) on delete cascade,
  read_chapters int not null default 0,
  primary key (user_id, book_id)
);

insert into public.bible_books (id, name, testament, chapters) values
  ('gen', 'Gênesis', 'old', 50),
  ('exo', 'Êxodo', 'old', 40),
  ('lev', 'Levítico', 'old', 27),
  ('num', 'Números', 'old', 36),
  ('deu', 'Deuteronômio', 'old', 34),
  ('jos', 'Josué', 'old', 24),
  ('jdg', 'Juízes', 'old', 21),
  ('rut', 'Rute', 'old', 4),
  ('1sa', '1 Samuel', 'old', 31),
  ('2sa', '2 Samuel', 'old', 24),
  ('1ki', '1 Reis', 'old', 22),
  ('2ki', '2 Reis', 'old', 25),
  ('1ch', '1 Crônicas', 'old', 29),
  ('2ch', '2 Crônicas', 'old', 36),
  ('ezr', 'Esdras', 'old', 10),
  ('neh', 'Neemias', 'old', 13),
  ('est', 'Ester', 'old', 10),
  ('job', 'Jó', 'old', 42),
  ('psa', 'Salmos', 'old', 150),
  ('pro', 'Provérbios', 'old', 31),
  ('ecc', 'Eclesiastes', 'old', 12),
  ('sng', 'Cânticos', 'old', 8),
  ('isa', 'Isaías', 'old', 66),
  ('jer', 'Jeremias', 'old', 52),
  ('lam', 'Lamentações', 'old', 5),
  ('ezk', 'Ezequiel', 'old', 48),
  ('dan', 'Daniel', 'old', 12),
  ('hos', 'Oséias', 'old', 14),
  ('jol', 'Joel', 'old', 3),
  ('amo', 'Amós', 'old', 9),
  ('oba', 'Obadias', 'old', 1),
  ('jon', 'Jonas', 'old', 4),
  ('mic', 'Miqueias', 'old', 7),
  ('nam', 'Naum', 'old', 3),
  ('hab', 'Habacuque', 'old', 3),
  ('zep', 'Sofonias', 'old', 3),
  ('hag', 'Ageu', 'old', 2),
  ('zec', 'Zacarias', 'old', 14),
  ('mal', 'Malaquias', 'old', 4),
  ('mat', 'Mateus', 'new', 28),
  ('mrk', 'Marcos', 'new', 16),
  ('luk', 'Lucas', 'new', 24),
  ('jhn', 'João', 'new', 21),
  ('act', 'Atos', 'new', 28),
  ('rom', 'Romanos', 'new', 16),
  ('1co', '1 Coríntios', 'new', 16),
  ('2co', '2 Coríntios', 'new', 13),
  ('gal', 'Gálatas', 'new', 6),
  ('eph', 'Efésios', 'new', 6),
  ('php', 'Filipenses', 'new', 4),
  ('col', 'Colossenses', 'new', 4),
  ('1th', '1 Tessalonicenses', 'new', 5),
  ('2th', '2 Tessalonicenses', 'new', 3),
  ('1ti', '1 Timóteo', 'new', 6),
  ('2ti', '2 Timóteo', 'new', 4),
  ('tit', 'Tito', 'new', 3),
  ('phm', 'Filemom', 'new', 1),
  ('heb', 'Hebreus', 'new', 13),
  ('jas', 'Tiago', 'new', 5),
  ('1pe', '1 Pedro', 'new', 5),
  ('2pe', '2 Pedro', 'new', 3),
  ('1jn', '1 João', 'new', 5),
  ('2jn', '2 João', 'new', 1),
  ('3jn', '3 João', 'new', 1),
  ('jud', 'Judas', 'new', 1),
  ('rev', 'Apocalipse', 'new', 22)
on conflict (id) do nothing;

create or replace function public.my_church_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select church_id from public.profiles where id = auth.uid();
$$;

create or replace function public.my_role()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.my_role() in ('leader', 'pastor');
$$;

create or replace function public.is_pastor()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.my_role() = 'pastor';
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  name text;
  initials text;
begin
  name := coalesce(nullif(trim(new.raw_user_meta_data->>'display_name'), ''), split_part(new.email, '@', 1), 'Você');
  initials := upper(substr(name, 1, 2));
  insert into public.profiles (id, display_name, initials, avatar_color, yvp_id)
  values (
    new.id,
    name,
    initials,
    14260659,
    nullif(trim(new.raw_user_meta_data->>'yvp_id'), '')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.seed_user_bookshelf(p_user uuid)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.book_progress (user_id, book_id, read_chapters)
  select p_user, id, 0 from public.bible_books
  on conflict do nothing;
$$;

create or replace function public.create_church(p_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  pid uuid;
  gid uuid;
  code text;
  i int;
  start_ch int;
  end_ch int;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  select church_id into cid from public.profiles where id = uid;
  if cid is not null then
    return cid;
  end if;

  code := public.random_invite_code();
  insert into public.churches (name, invite_code) values (trim(p_name), code) returning id into cid;
  update public.profiles set church_id = cid, role = 'pastor' where id = uid;

  insert into public.reading_plans (church_id, title)
  values (cid, 'Leitura da igreja')
  returning id into pid;

  for i in 0..13 loop
    start_ch := 1 + ((27 + i * 3) % 150);
    end_ch := least(start_ch + 2, 150);
    insert into public.plan_days (plan_id, day, passage_label, book, start_chapter, end_chapter)
    values (
      pid,
      (current_date + i),
      'Salmos ' || start_ch || '–' || end_ch,
      'Salmos',
      start_ch,
      end_ch
    );
  end loop;

  insert into public.groups (church_id, name, plan_label, plan_id, invite_code, created_by)
  values (cid, trim(p_name), 'Leitura da igreja', pid, public.random_invite_code(), uid)
  returning id into gid;
  insert into public.group_members (group_id, user_id) values (gid, uid);

  perform public.seed_user_bookshelf(uid);
  return cid;
end;
$$;

create or replace function public.create_group(p_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  gid uuid;
  pid uuid;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_staff() then
    raise exception 'not allowed';
  end if;
  select church_id into cid from public.profiles where id = uid;
  if cid is null then
    raise exception 'not in a church';
  end if;

  select id into pid from public.reading_plans where church_id = cid order by created_at limit 1;

  insert into public.groups (church_id, name, plan_label, plan_id, invite_code, created_by)
  values (
    cid,
    trim(p_name),
    coalesce((select title from public.reading_plans where id = pid), 'Leitura da igreja'),
    pid,
    public.random_invite_code(),
    uid
  )
  returning id into gid;
  insert into public.group_members (group_id, user_id) values (gid, uid);
  return gid;
end;
$$;

create or replace function public.assign_plan_to_group(p_group_id uuid, p_plan_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  g_church uuid;
  p_church uuid;
  g_owner uuid;
  plan_title text;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_staff() then
    raise exception 'not allowed';
  end if;

  select church_id into cid from public.profiles where id = uid;
  select church_id, created_by into g_church, g_owner from public.groups where id = p_group_id;
  select church_id, title into p_church, plan_title from public.reading_plans where id = p_plan_id;

  if cid is null or g_church is distinct from cid or p_church is distinct from cid then
    raise exception 'not allowed';
  end if;
  if public.my_role() = 'leader' and g_owner is distinct from uid then
    raise exception 'not allowed';
  end if;

  update public.groups
  set plan_id = p_plan_id, plan_label = coalesce(plan_title, plan_label)
  where id = p_group_id;

  insert into public.group_reading_plans (group_id, plan_id)
  values (p_group_id, p_plan_id)
  on conflict do nothing;
end;
$$;

create or replace function public.join_group(p_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  gid uuid;
  cid uuid;
  user_church uuid;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select id, church_id into gid, cid from public.groups where invite_code = upper(trim(p_code));
  if gid is null then
    raise exception 'invalid invite code';
  end if;

  select church_id into user_church from public.profiles where id = uid;

  if user_church is null then
    update public.profiles set church_id = cid, role = 'member' where id = uid;
    perform public.seed_user_bookshelf(uid);
  elsif user_church is distinct from cid then
    raise exception 'already in another church';
  end if;

  insert into public.group_members (group_id, user_id) values (gid, uid) on conflict do nothing;
  return gid;
end;
$$;

create or replace function public.join_church(p_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  gid uuid;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  if exists (select 1 from public.profiles where id = uid and church_id is not null) then
    raise exception 'already in a church';
  end if;

  select id into cid from public.churches where invite_code = upper(trim(p_code));
  if cid is null then
    raise exception 'invalid invite code';
  end if;

  update public.profiles set church_id = cid, role = 'member' where id = uid;
  select id into gid from public.groups where church_id = cid order by name limit 1;
  if gid is not null then
    insert into public.group_members (group_id, user_id) values (gid, uid) on conflict do nothing;
  end if;
  perform public.seed_user_bookshelf(uid);
  return cid;
end;
$$;

create or replace function public.log_reading(p_passage text, p_minutes int, p_note text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  lid uuid;
  book_name text;
  added_chapters int;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  select church_id into cid from public.profiles where id = uid;
  if cid is null then
    raise exception 'not in a church';
  end if;

  insert into public.reading_logs (user_id, church_id, passage_label, minutes, note, kind)
  values (uid, cid, p_passage, greatest(p_minutes, 1), nullif(trim(p_note), ''), 'progress')
  returning id into lid;

  book_name := split_part(p_passage, ' ', 1);
  added_chapters := 1;
  update public.book_progress bp
  set read_chapters = least(bb.chapters, bp.read_chapters + added_chapters)
  from public.bible_books bb
  where bp.user_id = uid
    and bp.book_id = bb.id
    and bb.name ilike book_name;

  return lid;
end;
$$;

alter table public.churches enable row level security;
alter table public.profiles enable row level security;
alter table public.reading_plans enable row level security;
alter table public.plan_days enable row level security;
alter table public.reading_logs enable row level security;
alter table public.reactions enable row level security;
alter table public.comments enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.bible_books enable row level security;
alter table public.book_progress enable row level security;

drop policy if exists churches_select on public.churches;
create policy churches_select on public.churches
  for select using (id = public.my_church_id());

drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select using (id = auth.uid() or church_id = public.my_church_id());

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists plans_select on public.reading_plans;
create policy plans_select on public.reading_plans
  for select using (church_id = public.my_church_id());

drop policy if exists plan_days_select on public.plan_days;
create policy plan_days_select on public.plan_days
  for select using (
    exists (
      select 1 from public.reading_plans p
      where p.id = plan_id and p.church_id = public.my_church_id()
    )
  );

drop policy if exists logs_select on public.reading_logs;
create policy logs_select on public.reading_logs
  for select using (church_id = public.my_church_id());

drop policy if exists reactions_all on public.reactions;
create policy reactions_select on public.reactions
  for select using (
    exists (select 1 from public.reading_logs l where l.id = log_id and l.church_id = public.my_church_id())
  );
create policy reactions_insert on public.reactions
  for insert with check (user_id = auth.uid());

drop policy if exists comments_select on public.comments;
create policy comments_select on public.comments
  for select using (
    exists (select 1 from public.reading_logs l where l.id = log_id and l.church_id = public.my_church_id())
  );

drop policy if exists groups_select on public.groups;
create policy groups_select on public.groups
  for select using (church_id = public.my_church_id());

drop policy if exists group_members_select on public.group_members;
create policy group_members_select on public.group_members
  for select using (
    exists (select 1 from public.groups g where g.id = group_id and g.church_id = public.my_church_id())
  );

drop policy if exists bible_books_select on public.bible_books;
create policy bible_books_select on public.bible_books
  for select using (true);

drop policy if exists book_progress_select on public.book_progress;
create policy book_progress_select on public.book_progress
  for select using (user_id = auth.uid());

grant usage on schema public to anon, authenticated;
grant select on public.churches, public.profiles, public.reading_plans, public.plan_days,
  public.reading_logs, public.reactions, public.comments, public.groups, public.group_members,
  public.bible_books, public.book_progress to authenticated;
grant insert on public.reactions to authenticated;
grant update on public.profiles to authenticated;
grant execute on function public.create_church(text) to authenticated;
grant execute on function public.create_group(text) to authenticated;
grant execute on function public.assign_plan_to_group(uuid, uuid) to authenticated;
grant execute on function public.join_group(text) to authenticated;
grant execute on function public.join_church(text) to authenticated;
grant execute on function public.log_reading(text, int, text) to authenticated;

-- Cuidado pastoral (check-in diário)

create table if not exists public.mood_checkins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  church_id uuid not null references public.churches (id) on delete cascade,
  day date not null default current_date,
  score int not null check (score between 1 and 5),
  body text,
  lgpd_accepted_at timestamptz,
  crisis boolean not null default false,
  status text not null default 'logged'
    check (status in ('logged', 'needs_care', 'analyzed', 'plan_sent', 'contact_scheduled')),
  created_at timestamptz not null default now(),
  unique (user_id, day)
);

create table if not exists public.pastoral_reports (
  id uuid primary key default gen_random_uuid(),
  checkin_id uuid not null unique references public.mood_checkins (id) on delete cascade,
  summary text not null,
  urgency text not null check (urgency in ('low', 'medium', 'high', 'critical')),
  theme text,
  duration_days int,
  passages jsonb not null default '[]'::jsonb,
  approach_notes jsonb not null default '[]'::jsonb,
  raw_model text,
  created_at timestamptz not null default now()
);

create table if not exists public.care_plans (
  id uuid primary key default gen_random_uuid(),
  church_id uuid not null references public.churches (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  report_id uuid references public.pastoral_reports (id) on delete set null,
  title text not null,
  message text,
  status text not null default 'active'
    check (status in ('active', 'archived')),
  archived_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.care_plan_days (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.care_plans (id) on delete cascade,
  day date not null,
  passage_label text not null,
  book text not null default '',
  start_chapter int not null default 1,
  end_chapter int not null default 1,
  unique (plan_id, day)
);

create table if not exists public.care_actions (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.pastoral_reports (id) on delete cascade,
  pastor_id uuid not null references public.profiles (id) on delete cascade,
  type text not null check (type in ('approve_plan', 'edit_plan', 'schedule_contact')),
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.submit_mood_checkin(p_score int, p_body text, p_lgpd boolean)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  rid uuid;
  st text;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  select church_id into cid from public.profiles where id = uid;
  if cid is null then
    raise exception 'not in a church';
  end if;
  if p_score < 1 or p_score > 5 then
    raise exception 'invalid score';
  end if;
  if p_score <= 2 and (p_lgpd is not true) then
    raise exception 'lgpd consent required';
  end if;

  st := case when p_score <= 2 then 'needs_care' else 'logged' end;

  insert into public.mood_checkins (user_id, church_id, day, score, body, lgpd_accepted_at, status)
  values (
    uid,
    cid,
    current_date,
    p_score,
    case when p_score <= 2 then nullif(trim(p_body), '') else null end,
    case when p_score <= 2 then now() else null end,
    st
  )
  on conflict (user_id, day) do update
    set score = excluded.score,
        body = excluded.body,
        lgpd_accepted_at = excluded.lgpd_accepted_at,
        status = excluded.status,
        crisis = false
  returning id into rid;

  if st = 'needs_care' then
    insert into public.pastoral_reports (checkin_id, summary, urgency)
    values (
      rid,
      coalesce(nullif(trim(p_body), ''), 'Membro pediu cuidado pastoral.'),
      case when p_score <= 1 then 'high' else 'medium' end
    )
    on conflict (checkin_id) do update
      set summary = excluded.summary,
          urgency = excluded.urgency;
  end if;

  return rid;
end;
$$;

create or replace function public.approve_care_plan(
  p_report_id uuid,
  p_title text,
  p_message text,
  p_passages text[],
  p_duration int
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  member_id uuid;
  checkin_id uuid;
  pid uuid;
  i int;
  n int;
  passage text;
begin
  if uid is null or not public.is_pastor() then
    raise exception 'not allowed';
  end if;
  select church_id into cid from public.profiles where id = uid;

  select mc.user_id, mc.id into member_id, checkin_id
  from public.pastoral_reports pr
  join public.mood_checkins mc on mc.id = pr.checkin_id
  where pr.id = p_report_id and mc.church_id = cid;

  if member_id is null then
    raise exception 'not allowed';
  end if;

  n := coalesce(array_length(p_passages, 1), 0);
  if n is null or n < 1 then
    p_passages := array['Salmos 23'];
    n := 1;
  end if;

  insert into public.care_plans (church_id, user_id, report_id, title, message)
  values (cid, member_id, p_report_id, coalesce(nullif(trim(p_title), ''), 'Leitura de cuidado'), p_message)
  returning id into pid;

  for i in 1..n loop
    passage := nullif(trim(coalesce(p_passages[i], '')), '');
    if passage is null then
      continue;
    end if;
    insert into public.care_plan_days (plan_id, day, passage_label, book, start_chapter, end_chapter)
    values (
      pid,
      current_date + (i - 1),
      passage,
      trim(regexp_replace(passage, '\s+\d+.*$', '')),
      coalesce(nullif(substring(passage from '\s(\d+)'), '')::int, 1),
      coalesce(nullif(substring(passage from '\s(\d+)'), '')::int, 1)
    );
  end loop;

  insert into public.care_actions (report_id, pastor_id, type, payload)
  values (p_report_id, uid, 'approve_plan', jsonb_build_object('plan_id', pid, 'title', p_title));

  update public.mood_checkins set status = 'plan_sent' where id = checkin_id;
  return pid;
end;
$$;

create or replace function public.schedule_care_contact(p_report_id uuid, p_when text, p_note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  checkin_id uuid;
begin
  if uid is null or not public.is_pastor() then
    raise exception 'not allowed';
  end if;
  select church_id into cid from public.profiles where id = uid;

  select mc.id into checkin_id
  from public.pastoral_reports pr
  join public.mood_checkins mc on mc.id = pr.checkin_id
  where pr.id = p_report_id and mc.church_id = cid;

  if checkin_id is null then
    raise exception 'not allowed';
  end if;

  insert into public.care_actions (report_id, pastor_id, type, payload)
  values (
    p_report_id,
    uid,
    'schedule_contact',
    jsonb_build_object('when', p_when, 'note', p_note)
  );
  update public.mood_checkins set status = 'contact_scheduled' where id = checkin_id;
end;
$$;

alter table public.mood_checkins enable row level security;
alter table public.pastoral_reports enable row level security;
alter table public.care_plans enable row level security;
alter table public.care_plan_days enable row level security;
alter table public.care_actions enable row level security;

drop policy if exists mood_own_select on public.mood_checkins;
create policy mood_own_select on public.mood_checkins
  for select using (user_id = auth.uid());

drop policy if exists mood_pastor_select on public.mood_checkins;
create policy mood_pastor_select on public.mood_checkins
  for select using (church_id = public.my_church_id() and public.is_pastor());

drop policy if exists reports_pastor_select on public.pastoral_reports;
create policy reports_pastor_select on public.pastoral_reports
  for select using (
    public.is_pastor() and exists (
      select 1 from public.mood_checkins mc
      where mc.id = checkin_id and mc.church_id = public.my_church_id()
    )
  );

drop policy if exists care_plans_own on public.care_plans;
create policy care_plans_own on public.care_plans
  for select using (user_id = auth.uid() or (public.is_pastor() and church_id = public.my_church_id()));

drop policy if exists care_plan_days_select on public.care_plan_days;
create policy care_plan_days_select on public.care_plan_days
  for select using (
    exists (
      select 1 from public.care_plans p
      where p.id = plan_id and (p.user_id = auth.uid() or (public.is_pastor() and p.church_id = public.my_church_id()))
    )
  );

drop policy if exists care_actions_pastor on public.care_actions;
create policy care_actions_pastor on public.care_actions
  for select using (
    public.is_pastor() and exists (
      select 1 from public.pastoral_reports pr
      join public.mood_checkins mc on mc.id = pr.checkin_id
      where pr.id = report_id and mc.church_id = public.my_church_id()
    )
  );

grant select on public.mood_checkins, public.pastoral_reports, public.care_plans,
  public.care_plan_days, public.care_actions to authenticated;
grant execute on function public.submit_mood_checkin(int, text, boolean) to authenticated;
grant execute on function public.approve_care_plan(uuid, text, text, text[], int) to authenticated;
grant execute on function public.schedule_care_contact(uuid, text, text) to authenticated;

alter table public.care_plans add column if not exists status text;
alter table public.care_plans add column if not exists archived_at timestamptz;
update public.care_plans set status = 'active' where status is null;
alter table public.care_plans alter column status set default 'active';

create table if not exists public.care_plan_reflections (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null unique references public.care_plans (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  church_id uuid not null references public.churches (id) on delete cascade,
  comment_text text,
  takeaway text not null default '',
  understanding int not null check (understanding between 1 and 5),
  reception text not null check (reception in (
    'paz', 'consolo', 'esperanca', 'encorajamento', 'desafio', 'ainda_pesado'
  )),
  minutes int not null default 1 check (minutes >= 1),
  created_at timestamptz not null default now()
);

alter table public.care_plan_reflections enable row level security;

drop policy if exists reflections_own on public.care_plan_reflections;
create policy reflections_own on public.care_plan_reflections
  for select using (
    user_id = auth.uid()
    or (public.is_pastor() and church_id = public.my_church_id())
  );

grant select on public.care_plan_reflections to authenticated;

create or replace function public.complete_care_plan(
  p_plan_id uuid,
  p_comment text,
  p_takeaway text,
  p_understanding int,
  p_reception text,
  p_minutes int
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  owner uuid;
  rid uuid;
  rec text;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  if p_understanding < 1 or p_understanding > 5 then
    raise exception 'invalid understanding';
  end if;
  rec := coalesce(nullif(trim(p_reception), ''), 'paz');
  if rec not in ('paz', 'consolo', 'esperanca', 'encorajamento', 'desafio', 'ainda_pesado') then
    raise exception 'invalid reception';
  end if;

  select church_id, user_id into cid, owner
  from public.care_plans
  where id = p_plan_id
    and status = 'active';

  if owner is null or owner <> uid then
    raise exception 'not allowed';
  end if;

  insert into public.care_plan_reflections (
    plan_id, user_id, church_id, comment_text, takeaway, understanding, reception, minutes
  )
  values (
    p_plan_id,
    uid,
    cid,
    nullif(trim(p_comment), ''),
    coalesce(nullif(trim(p_takeaway), ''), ''),
    p_understanding,
    rec,
    greatest(coalesce(p_minutes, 1), 1)
  )
  on conflict (plan_id) do update
    set comment_text = excluded.comment_text,
        takeaway = excluded.takeaway,
        understanding = excluded.understanding,
        reception = excluded.reception,
        minutes = excluded.minutes
  returning id into rid;

  update public.care_plans
  set status = 'archived', archived_at = now()
  where id = p_plan_id;

  return rid;
end;
$$;

grant execute on function public.complete_care_plan(uuid, text, text, int, text, int) to authenticated;

create table if not exists public.group_reading_plans (
  group_id uuid not null references public.groups (id) on delete cascade,
  plan_id uuid not null references public.reading_plans (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (group_id, plan_id)
);

insert into public.group_reading_plans (group_id, plan_id)
select id, plan_id from public.groups
where plan_id is not null
on conflict do nothing;

create table if not exists public.group_passage_comments (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  plan_id uuid references public.reading_plans (id) on delete cascade,
  passage_label text not null,
  user_id uuid not null references public.profiles (id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create or replace function public.is_group_member(p_group uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.group_members
    where group_id = p_group and user_id = auth.uid()
  );
$$;

alter table public.group_reading_plans enable row level security;
alter table public.group_passage_comments enable row level security;

drop policy if exists group_reading_plans_select on public.group_reading_plans;
create policy group_reading_plans_select on public.group_reading_plans
  for select using (
    exists (
      select 1 from public.groups g
      where g.id = group_id and g.church_id = public.my_church_id()
    )
  );

drop policy if exists group_comments_select on public.group_passage_comments;
create policy group_comments_select on public.group_passage_comments
  for select using (public.is_group_member(group_id) or public.is_staff());

drop policy if exists group_comments_insert on public.group_passage_comments;
create policy group_comments_insert on public.group_passage_comments
  for insert with check (user_id = auth.uid() and public.is_group_member(group_id));

grant select on public.group_reading_plans, public.group_passage_comments to authenticated;
grant insert on public.group_passage_comments to authenticated;

create or replace function public.create_group_plan(
  p_group_id uuid,
  p_title text,
  p_passages text[]
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  cid uuid;
  g_church uuid;
  pid uuid;
  i int;
  n int;
  passage text;
begin
  if uid is null or not public.is_staff() then
    raise exception 'not allowed';
  end if;
  select church_id into cid from public.profiles where id = uid;
  select church_id into g_church from public.groups where id = p_group_id;
  if cid is null or g_church is distinct from cid then
    raise exception 'not allowed';
  end if;

  n := coalesce(array_length(p_passages, 1), 0);
  if n is null or n < 1 then
    raise exception 'passages required';
  end if;

  insert into public.reading_plans (church_id, title)
  values (cid, coalesce(nullif(trim(p_title), ''), 'Leitura do grupo'))
  returning id into pid;

  for i in 1..n loop
    passage := nullif(trim(coalesce(p_passages[i], '')), '');
    if passage is null then
      continue;
    end if;
      insert into public.plan_days (plan_id, day, passage_label, book, start_chapter, end_chapter)
    values (
      pid,
      current_date + (i - 1),
      passage,
      coalesce(nullif(trim(regexp_replace(passage, '\s+\d+.*$', '')), ''), 'Bíblia'),
      coalesce(nullif(substring(passage from '\s(\d+)'), '')::int, 1),
      coalesce(nullif(substring(passage from '\s(\d+)'), '')::int, 1)
    );
  end loop;

    insert into public.group_reading_plans (group_id, plan_id)
  values (p_group_id, pid)
  on conflict do nothing;

  if not exists (select 1 from public.plan_days where plan_id = pid) then
    delete from public.group_reading_plans where plan_id = pid;
    delete from public.reading_plans where id = pid;
    raise exception 'passages required';
  end if;

  update public.groups
  set plan_id = pid, plan_label = coalesce(nullif(trim(p_title), ''), plan_label)
  where id = p_group_id;

  return pid;
end;
$$;

grant execute on function public.create_group_plan(uuid, text, text[]) to authenticated;
grant execute on function public.is_group_member(uuid) to authenticated;

create table if not exists public.group_plan_completions (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  plan_id uuid not null references public.reading_plans (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  comment_text text,
  takeaway text not null default '',
  understanding int not null check (understanding between 1 and 5),
  reception text not null check (reception in (
    'paz', 'consolo', 'esperanca', 'encorajamento', 'desafio', 'ainda_pesado'
  )),
  minutes int not null default 1 check (minutes >= 1),
  created_at timestamptz not null default now(),
  unique (group_id, plan_id, user_id)
);

alter table public.group_plan_completions enable row level security;

drop policy if exists group_completions_select on public.group_plan_completions;
create policy group_completions_select on public.group_plan_completions
  for select using (public.is_group_member(group_id) or public.is_staff());

grant select on public.group_plan_completions to authenticated;

create or replace function public.complete_group_plan(
  p_group_id uuid,
  p_plan_id uuid,
  p_comment text,
  p_takeaway text,
  p_understanding int,
  p_reception text,
  p_minutes int
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  rid uuid;
  rec text;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_group_member(p_group_id) then
    raise exception 'not allowed';
  end if;
  if p_understanding < 1 or p_understanding > 5 then
    raise exception 'invalid understanding';
  end if;
  rec := coalesce(nullif(trim(p_reception), ''), 'paz');
  if rec not in ('paz', 'consolo', 'esperanca', 'encorajamento', 'desafio', 'ainda_pesado') then
    raise exception 'invalid reception';
  end if;
  if not exists (
    select 1 from public.group_reading_plans
    where group_id = p_group_id and plan_id = p_plan_id
  ) then
    raise exception 'plan not in group';
  end if;

  insert into public.group_plan_completions (
    group_id, plan_id, user_id, comment_text, takeaway, understanding, reception, minutes
  )
  values (
    p_group_id,
    p_plan_id,
    uid,
    nullif(trim(p_comment), ''),
    coalesce(nullif(trim(p_takeaway), ''), ''),
    p_understanding,
    rec,
    greatest(coalesce(p_minutes, 1), 1)
  )
  on conflict (group_id, plan_id, user_id) do update
    set comment_text = excluded.comment_text,
        takeaway = excluded.takeaway,
        understanding = excluded.understanding,
        reception = excluded.reception,
        minutes = excluded.minutes
  returning id into rid;

  return rid;
end;
$$;

grant execute on function public.complete_group_plan(uuid, uuid, text, text, int, text, int) to authenticated;
