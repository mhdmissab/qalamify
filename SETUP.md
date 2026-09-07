# Qalamify site — Supabase setup guide

This connects the registration form, mentor section, and admin panel to a real database with real login security and real photo uploads. Total time: about 15 minutes.

## What each file does

| File | Purpose |
|---|---|
| `index.html` | The main site |
| `registration.html` | The admission form |
| `admin.html` | Password-protected CMS panel — **never link to this from your public menu** |
| `assets/config.js` | The one file where you paste your Supabase URL and key |
| `assets/site.js` | Shared code that reads from the database — no need to touch this |
| `supabase-schema.sql` | Sets up your database — you'll paste this into Supabase once |

---

## 1. Create a Supabase account and project

1. Go to [supabase.com](https://supabase.com) → **Start your project** → sign up (free, no credit card needed for this).
2. Click **New project**.
3. Give it a name like `qalamify`, set a database password (save this somewhere — you likely won't need it again, but keep it safe), pick the region closest to you.
4. Click **Create new project** and wait a minute or two while it sets up.

## 2. Run the database setup script

1. In your new project, click **SQL Editor** in the left sidebar.
2. Click **New query**.
3. Open `supabase-schema.sql` (included with your files), copy its entire contents, and paste into the query box.
4. Click **Run** (bottom right).
5. You should see "Success. No rows returned." This created 3 tables, locked them down with security rules, and set up photo storage.

## 3. Create your admin login

1. In the left sidebar, click **Authentication** → **Users**.
2. Click **Add user** → **Create new user**.
3. Enter the email and password you want to log into `admin.html` with.
4. Leave "Auto Confirm User" turned on, then create the user.

This is the only account that can log into your admin panel — there's no public sign-up.

## 4. Get your API keys

1. Click the **Settings** (gear icon) in the left sidebar → **API**.
2. You'll see two things you need:
   - **Project URL** — looks like `https://abcdefgh.supabase.co`
   - **anon public** key — a long string under "Project API keys"

## 5. Fill in the config

Open `assets/config.js` and paste both values in:

```javascript
const QALAMIFY_CONFIG = {
  SUPABASE_URL: "https://abcdefgh.supabase.co",
  SUPABASE_ANON_KEY: "your anon public key here"
};
```

Save, then upload it to GitHub the same way you've been doing (edit the file → replace contents → commit), or re-upload the whole folder.

## 6. Test it

- **Registration form:** submit a test entry on `registration.html`. In Supabase, click **Table Editor** → `registrations` → your entry should be there.
- **Admin login:** open `admin.html`, sign in with the email/password from Step 3.
- **Mentors:** in the admin panel's Mentors tab, add a test mentor with a photo → refresh `index.html` → the mentor card should appear within a few seconds, photo included.
- **Contact details:** save a new email/phone in the admin panel → refresh `index.html` → the footer should update.

## How the photo upload works

Unlike the old Google Sheets version, you no longer need to paste image links. In the admin panel's Mentors tab, click **Choose File**, pick a photo from your device, and it uploads directly and securely — the link is filled in automatically.

## Security notes

- The `anon public` key in `config.js` is meant to be public — it's safe to have it visible in your site's code. What actually protects your data are the security rules in `supabase-schema.sql` (anyone can *read* mentors/settings, but only someone logged in as your admin user can *write*).
- Passwords are hashed and managed entirely by Supabase — you never see or store them yourself.
- `admin.html` has no public sign-up — only the user(s) you create in Step 3 can log in.
- Don't link to `admin.html` from anywhere on your public site menu. Anyone with the link still can't do anything without the correct password, but there's no reason to advertise it.

## If something breaks

- **"Couldn't load mentors" / blank sections:** double-check `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `config.js` — a typo is the most common cause.
- **Login fails:** confirm the user exists under Authentication → Users in Supabase, and that "Auto Confirm User" was checked when you created it.
- **Photo doesn't show after upload:** refresh the admin page — the upload itself may have succeeded even if the preview didn't update.
