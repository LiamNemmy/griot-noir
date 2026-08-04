Supabase migration guide — move images into a public storage bucket ("images") and enable realtime

This repository contains a static single-file site (index.html) that currently uses bundled LOCAL_WIRE image URLs.
The files added on branch supabase-images-storage provide helpers and instructions to:

- resolve images routed through Supabase Storage (bucket: "images")
- subscribe to realtime changes on the works table and notify the page via a DOM event

What I added
- supabase/init.js  — JS helpers to initialize Supabase, resolve image paths from the "images" bucket,
  normalize DB rows, and dispatch a "griot:feed:changed" event when the works table changes.
- config.json.example — example runtime config used by supabase/init.js

How to wire this into index.html (two small edits)
1) Add the helper script
   Insert the following tag somewhere BEFORE the inline script that currently contains GRIOT_CONFIG and loadFeed():

   <script src="/supabase/init.js"></script>

2) Initialize at boot
   Near the bottom of the inline <script> (in index.html) replace the current boot block that calls loadFeed() with an async init sequence, for example:

   (async function(){
     // initialize supabase helpers; will use /config.json or fallback to inline GRIOT_CONFIG
     if(window.GRIOT_SUPABASE && window.GRIOT_SUPABASE.init){
       try{ await window.GRIOT_SUPABASE.init(); }
       catch(e){ console.warn('GRIOT SUPABASE init failed', e); }
     }

     // re-load the feed when the DB emits real-time changes
     window.addEventListener('griot:feed:changed', function(ev){
       // optional: debounce to avoid storm reloads
       if(window.__griot_feed_reload) clearTimeout(window.__griot_feed_reload);
       window.__griot_feed_reload = setTimeout(function(){ loadFeed(); }, 300);
     });

     // normal boot
     loadFeed();
     renderWall();
   })();

3) Adapt liveFeed mapping (recommended)
   If you use the liveFeed() path that fetches rows from Supabase, prefer the provided mapRowFromDb helper so storage paths are resolved.
   Replace the mapping in liveFeed's then() with:

   return Promise.all((res.data || []).map(function(r){ return window.mapRowFromDb(r); }));

   This returns the exact same mapped objects the renderer expects (including image_url resolved from storage).

Uploading images to the bucket

- Create a public bucket named "images" in Supabase Storage.
- Upload files with paths that you will reference in the works table (e.g. "2026/186d55f54-5ec8-4d91-9096-002789004325.png").
- In your works rows set image_path to the storage path (NOT the full URL). Example SQL (update seed rows):

  UPDATE works SET image_path = '2026/186d55f54-5ec8-4d91-9096-002789004325.png' WHERE id = 'lw-01';

- The frontend will call supabase.storage.from('images').getPublicUrl(image_path) to form the public URL.

RLS and security notes
- Keep using anonymous (publishable) keys for the frontend but ensure Row Level Security (RLS) policies allow only published rows to be read by anon users (this project already documents that pattern).
- Public bucket: files will be served publicly. If you need privacy, store files in a private bucket and use signed URLs (supabase.storage.from(bucket).createSignedUrl(path, expiresInSeconds)).

Want me to also:
- Modify index.html in-place to automatically include the helper and the init sequence, and update liveFeed to use mapRowFromDb? (I can open a PR on your behalf.)
- Upload images into the "images" bucket using the Supabase API? (I cannot access your Supabase project directly; I can provide a script you can run locally.)

If you want the automated index.html edits, say "apply changes to index.html" and I will create a PR/branch that updates the file and wires everything together.
