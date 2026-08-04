/* supabase/init.js

  Lightweight Supabase integration helpers for GRIOT NOIR
  - Loads runtime config from /config.json (fallback to inline GRIOT_CONFIG)
  - Initializes supabase client (v2+) when keys are present
  - Exposes resolveImageUrl(row) to prefer storage bucket paths (bucket: "images")
  - Exposes mapRowFromDb(row) to normalize a DB row into the feed shape
  - Subscribes to realtime Postgres changes on public.works and dispatches
    a custom DOM event 'griot:feed:changed' so the page can reload the feed.

  Usage (minimal):
    1) Add <script src="/supabase/init.js"></script> BEFORE your bundled inline script
    2) In your inline script call: await GRIOT_SUPABASE.init();
       then call loadFeed() as before. Also add: document.addEventListener('griot:feed:changed', loadFeed);

  Notes:
  - Default bucket name is 'images'. You can override via config.json: {"IMAGE_BUCKET":"my-bucket"}
  - This helper does not modify your feed rendering. It simply resolves storage URLs
    and notifies the page when the DB changes.
*/
(function(){
  'use strict';
  if(window.GRIOT_SUPABASE) return; // idempotent

  var G = {
    db: null,
    cfg: { SUPABASE_URL: null, SUPABASE_ANON_KEY: null, IMAGE_BUCKET: 'images' },
    initialized: false
  };

  function safeJsonParse(text){ try{ return JSON.parse(text); }catch(e){return null;} }

  async function loadRuntimeConfig(){
    // Try /config.json (deploy-time templating)
    try{
      var res = await fetch('/config.json', {cache: 'no-store'});
      if(res.ok){
        var json = await res.json();
        return Object.assign({}, G.cfg, json || {});
      }
    }catch(e){}
    // fallback to inline GRIOT_CONFIG if present
    if(typeof window.GRIOT_CONFIG === 'object' && window.GRIOT_CONFIG){
      return Object.assign({}, G.cfg, window.GRIOT_CONFIG);
    }
    return G.cfg;
  }

  async function init(){
    if(G.initialized) return G;
    G.cfg = await loadRuntimeConfig();

    if(G.cfg.SUPABASE_URL && G.cfg.SUPABASE_ANON_KEY && window.supabase && typeof window.supabase.createClient === 'function'){
      try{
        G.db = window.supabase.createClient(G.cfg.SUPABASE_URL, G.cfg.SUPABASE_ANON_KEY);

        // subscribe to realtime changes on public.works
        try{
          // v2 channel API
          G.db.channel('public:works')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'works' }, function(payload){
              // dispatch a DOM event the page can listen for
              var ev = new CustomEvent('griot:feed:changed', { detail: payload });
              window.dispatchEvent(ev);
            })
            .subscribe({ callTimeout: 30000 })
            .then(function(){ /* subscribed */ })
            .catch(function(err){ console.warn('GRIOT_SUPABASE: realtime subscribe failed', err); });
        }catch(e){ console.warn('GRIOT_SUPABASE: realtime setup failed', e); }

      }catch(e){
        G.db = null;
        console.warn('GRIOT_SUPABASE: init error', e);
      }
    }

    G.initialized = true;
    // expose helpers
    window.resolveImageUrl = resolveImageUrl;
    window.mapRowFromDb = mapRowFromDb;
    window.GRIOT_SUPABASE = Object.assign({}, G, { init: init });
    return window.GRIOT_SUPABASE;
  }

  async function resolveImageUrl(row){
    // Prefer image_path (storage path) -> use public URL from storage bucket
    try{
      if(row && row.image_path && G.db && G.cfg.IMAGE_BUCKET && G.db.storage){
        try{
          // supabase-js v2 returns { data: { publicUrl } }
          var res = G.db.storage.from(G.cfg.IMAGE_BUCKET).getPublicUrl(row.image_path);
          if(res && res.data && res.data.publicUrl) return res.data.publicUrl;
          if(res && res.publicURL) return res.publicURL; // older shape fallback
        }catch(e){ console.warn('GRIOT_SUPABASE: storage.getPublicUrl failed', e); }
      }
    }catch(e){/* swallow */}
    // fallback to image_url if present, or null
    return row && (row.image_url || null);
  }

  // normalize a DB row into the shape the renderer expects
  async function mapRowFromDb(row){
    if(!row) return null;
    // creators mapping: supports either work_creators relationship or work_creators_json
    var creators = [];
    try{
      if(Array.isArray(row.work_creators) && row.work_creators.length){
        creators = (row.work_creators || []).slice().sort(function(a,b){ return (a.position||0)-(b.position||0); })
          .map(function(wc){ return { name: (wc.person && wc.person.name) || wc.name || 'Unknown', role: wc.role || 'Contributor' }; });
      } else if(row.creators_json){
        // optional seed format
        try{ creators = JSON.parse(row.creators_json); }catch(e){}
      }
    }catch(e){}

    var cats = [], catSlugs = [], tags = [], tagSlugs = [];
    try{
      (row.work_terms || []).forEach(function(wt){ var t = wt && wt.term; if(!t) return; if(t.type === 'category'){ cats.push(t.name); catSlugs.push(t.slug); } else if(t.type === 'tag'){ tags.push(t.name); tagSlugs.push(t.slug); } });
    }catch(e){}

    var mapped = {
      id: row.id || row._id || null,
      slug: row.slug || null,
      title: row.title || row.name || '',
      subtitle: row.subtitle || null,
      summary: row.summary || row.description || null,
      type: row.type || 'article',
      featured: !!row.featured,
      pinned: !!row.pinned,
      editorial_weight: row.editorial_weight || row.weight || 0,
      published_at: row.published_at || row.publishedAt || row.created_at || null,
      image_url: row.image_url || null, // will be overridden by resolveImageUrl if image_path exists
      image_alt: row.image_alt || row.imageAlt || null,
      creators: creators,
      categories: cats,
      category_slugs: catSlugs,
      tags: tags,
      tag_slugs: tagSlugs,
      // passthrough for storage path if present
      image_path: row.image_path || row.imagePath || null
    };

    // resolve storage path to a public URL if possible
    try{
      var url = await resolveImageUrl(row);
      if(url) mapped.image_url = url;
    }catch(e){}

    return mapped;
  }

  // export
  window.GRIOT_SUPABASE = {
    init: init,
    resolveImageUrl: resolveImageUrl,
    mapRowFromDb: mapRowFromDb
  };
})();
