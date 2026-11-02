-- Supabase SQL Editor: کل این فایل را یک‌بار اجرا کنید.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  track text default 'student',
  created_at timestamptz not null default now()
);

create table if not exists public.progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  scenario_id text not null,
  spine text,
  track text,
  option_index int not null,
  is_best boolean not null,
  welfare int, trust int, risk int,
  created_at timestamptz not null default now(),
  unique (user_id, scenario_id)
);

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

create or replace function public.is_admin() returns boolean
language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- ساخت خودکار پروفایل هنگام ثبت‌نام
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name, track)
  values (new.id,
          coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email,'@',1)),
          coalesce(new.raw_user_meta_data->>'track', 'student'))
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

alter table public.profiles enable row level security;
alter table public.progress enable row level security;
alter table public.attempts enable row level security;
alter table public.admins   enable row level security;

-- هر کاربر فقط داده‌ی خودش را می‌بیند و می‌نویسد؛ ادمین همه را می‌خواند.
create policy "profiles read"  on public.profiles for select using (id = auth.uid() or public.is_admin());
create policy "profiles write" on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());

create policy "progress read"   on public.progress for select using (user_id = auth.uid() or public.is_admin());
create policy "progress insert" on public.progress for insert with check (user_id = auth.uid());
create policy "progress update" on public.progress for update using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "attempts read"   on public.attempts for select using (user_id = auth.uid() or public.is_admin());
create policy "attempts insert" on public.attempts for insert with check (user_id = auth.uid());
create policy "attempts update" on public.attempts for update using (user_id = auth.uid()) with check (user_id = auth.uid());

-- جدول admins را فقط از داشبورد پر کنید (هیچ policy ای ندارد).

-- نمونه گزارش برای ادمین (در SQL Editor):
-- select p.display_name, count(*) as answered, round(100*avg(a.is_best::int)) as pct_best
-- from attempts a join profiles p on p.id = a.user_id group by p.display_name order by pct_best desc;
