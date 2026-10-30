-- Bookings for projects, products, services and courses, plus an admin list.
--
-- Admins are deliberately NOT a column on profiles: users can update their own
-- profile row, so anything stored there could be self-assigned. Add admins from
-- the SQL editor / service role only, e.g.
--   insert into public.admins (user_id)
--   select id from auth.users where phone = '919876543210';

create table public.admins (
  user_id uuid primary key references auth.users on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admins enable row level security;
-- No policies: clients cannot read or write this table directly.

create function public.is_admin() returns boolean
language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;
revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

create type public.booking_type as enum ('project', 'product', 'service', 'course');
create type public.booking_status as enum ('pending', 'confirmed', 'completed', 'cancelled');

create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  type public.booking_type not null,
  item_title text not null check (char_length(item_title) between 1 and 200),
  customer_name text not null check (char_length(customer_name) between 1 and 100),
  phone text not null check (char_length(phone) between 5 and 20),
  preferred_date date,
  notes text check (char_length(notes) <= 1000),
  status public.booking_status not null default 'pending',
  admin_notes text check (char_length(admin_notes) <= 1000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index bookings_user_idx on public.bookings (user_id, created_at desc);
create index bookings_status_idx on public.bookings (status, created_at desc);

create function public.touch_updated_at() returns trigger
language plpgsql set search_path = public as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
create trigger bookings_touch before update on public.bookings
  for each row execute function public.touch_updated_at();

alter table public.bookings enable row level security;

create policy "Users create own pending bookings" on public.bookings
  for insert to authenticated
  with check (user_id = auth.uid() and status = 'pending');

create policy "Users read own bookings, admins read all" on public.bookings
  for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

create policy "Admins update bookings" on public.bookings
  for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- Users may only cancel their own still-pending booking (and nothing else).
create function public.cancel_booking(p_id uuid) returns void
language sql security definer set search_path = public as $$
  update public.bookings
     set status = 'cancelled'
   where id = p_id and user_id = auth.uid() and status = 'pending';
$$;
revoke all on function public.cancel_booking(uuid) from public, anon;
grant execute on function public.cancel_booking(uuid) to authenticated;
