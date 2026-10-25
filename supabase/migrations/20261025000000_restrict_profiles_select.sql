-- Profiles hold phone numbers and pincodes; the original policy let anyone with
-- the (public) anon key read every row. Restrict reads to the owner.
drop policy if exists "Public profiles are viewable by everyone." on public.profiles;

create policy "Users can view own profile." on public.profiles
  for select using (auth.uid() = id);

-- Updates must not be able to re-assign the row to another user.
drop policy if exists "Users can update own profile." on public.profiles;
create policy "Users can update own profile." on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);
