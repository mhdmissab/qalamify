-- ============================================================================
-- QALAMIFY DATABASE SETUP
-- Paste this entire file into Supabase's SQL Editor and click Run.
-- It creates 3 tables, locks them down with security rules, and sets up
-- a storage bucket for mentor photos.
-- ============================================================================

-- Site-wide settings (contact email, phone, etc.) as simple key/value rows
create table site_settings (
  key text primary key,
  value text
);

-- Mentor / faculty cards shown on the site
create table mentors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text,
  photo_url text,
  display_order int default 0,
  active boolean default true,
  created_at timestamptz default now()
);

-- Admission form submissions
create table registrations (
  id uuid primary key default gen_random_uuid(),
  full_name text,
  email text,
  phone text,
  program text,
  batch text,
  city text,
  message text,
  created_at timestamptz default now()
);

-- ============================================================================
-- SECURITY RULES (Row Level Security)
-- These control who can read/write each table from the public website.
-- ============================================================================
alter table site_settings enable row level security;
alter table mentors enable row level security;
alter table registrations enable row level security;

-- site_settings: everyone can read, only a logged-in admin can change
create policy "public read settings" on site_settings for select using (true);
create policy "admin write settings" on site_settings for insert with check (auth.role() = 'authenticated');
create policy "admin update settings" on site_settings for update using (auth.role() = 'authenticated');

-- mentors: everyone can read, only a logged-in admin can add/edit/delete
create policy "public read mentors" on mentors for select using (true);
create policy "admin insert mentors" on mentors for insert with check (auth.role() = 'authenticated');
create policy "admin update mentors" on mentors for update using (auth.role() = 'authenticated');
create policy "admin delete mentors" on mentors for delete using (auth.role() = 'authenticated');

-- registrations: anyone can submit the form, only a logged-in admin can view entries
create policy "public submit registration" on registrations for insert with check (true);
create policy "admin read registrations" on registrations for select using (auth.role() = 'authenticated');

-- ============================================================================
-- STARTING DATA
-- ============================================================================
insert into site_settings (key, value) values
  ('email', 'admin@qalamify.in'),
  ('phone', '8086307666');

-- ============================================================================
-- STORAGE BUCKET for mentor photos (real file uploads, not links)
-- ============================================================================
insert into storage.buckets (id, name, public) values ('media', 'media', true);

create policy "public view photos" on storage.objects for select using (bucket_id = 'media');
create policy "admin upload photos" on storage.objects for insert with check (bucket_id = 'media' and auth.role() = 'authenticated');
create policy "admin delete photos" on storage.objects for delete using (bucket_id = 'media' and auth.role() = 'authenticated');
