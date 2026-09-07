// ============================================================================
// Shared helpers: talk to Supabase and apply the data to the page.
// Requires the Supabase JS library and config.js to be loaded first.
// ============================================================================

const sbClient = supabase.createClient(QALAMIFY_CONFIG.SUPABASE_URL, QALAMIFY_CONFIG.SUPABASE_ANON_KEY);

/** Apply email/phone from site_settings to every element with a data-field attribute. */
async function applySiteSettings() {
  try {
    const { data, error } = await sbClient.from('site_settings').select('*');
    if (error || !data) return;
    const map = {};
    data.forEach(r => { map[r.key] = r.value; });

    document.querySelectorAll('[data-field="email"]').forEach(el => {
      if (!map.email) return;
      el.textContent = map.email;
      if (el.tagName === 'A') el.href = 'mailto:' + map.email;
    });
    document.querySelectorAll('[data-field="phone"]').forEach(el => {
      if (!map.phone) return;
      const digits = String(map.phone).replace(/\D/g, '');
      el.textContent = map.phone;
      if (el.tagName === 'A') el.href = 'tel:+91' + digits;
    });
  } catch (err) {
    // Supabase not configured yet — leave static content as-is.
  }
}

/** Load active mentors, sorted by display order, and render into a container. */
async function loadMentors(containerId) {
  const el = document.getElementById(containerId);
  if (!el) return;
  try {
    const { data, error } = await sbClient
      .from('mentors')
      .select('*')
      .eq('active', true)
      .order('display_order', { ascending: true });

    if (error || !data || data.length === 0) return; // keep the static fallback cards

    el.innerHTML = data.map(m => {
      const initials = String(m.name).trim().split(/\s+/).map(w => w[0]).slice(0, 2).join('').toUpperCase();
      const photo = m.photo_url
        ? `<img src="${m.photo_url}" alt="${m.name}" style="width:100%;height:100%;object-fit:cover;border-radius:16px;">`
        : initials;
      return `
        <div class="mentor-card">
          <div class="mentor-avatar">${photo}</div>
          <h3>${m.name}</h3>
          <span>${m.role || ''}</span>
        </div>`;
    }).join('');
  } catch (err) {
    // Supabase not configured yet — leave static content as-is.
  }
}
