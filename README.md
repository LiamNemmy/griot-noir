# GRIOT NOIR

> Dispatches from Africa & the underground of the world.

A single-file, no-build-step news/zine site (`index.html`) with a punchy
noir/graffiti design system. It ships with a bundled offline dataset
(`LOCAL_WIRE`) so the page always renders, and can optionally connect to
a [Supabase](https://supabase.com) backend for a live, editable feed.

## Structure

```
.
├── index.html          # the entire site: markup, CSS, and JS
└── supabase/
    ├── schema.sql       # tables, indexes, RLS policies
    └── seed.sql         # sample content matching the bundled LOCAL_WIRE data
```

## Running it locally

No build step required — it's a static file.

```bash
python3 -m http.server 8000
# then open http://localhost:8000
```

Or just open `index.html` directly in a browser.

## Going live with Supabase

1. Create a project at [supabase.com](https://supabase.com).
2. In the SQL Editor, run `supabase/schema.sql`, then `supabase/seed.sql`.
3. In `index.html`, find the `GRIOT_CONFIG` object near the top of the
   `<script>` block and fill in your project URL and anon/public key:

   ```js
   var GRIOT_CONFIG = {
     SUPABASE_URL: "https://your-project.supabase.co",
     SUPABASE_ANON_KEY: "your-anon-key"
   };
   ```

   Both values are safe to expose client-side — Row Level Security in
   `schema.sql` only ever serves rows where `status = 'published'`.

4. Reload the page. The feed status indicator in the top-right of the
   masthead will tell you what's happening:
   - `FEED · LOCAL WIRE` — no Supabase keys set, serving the bundled data
   - `FEED · SUPABASE LIVE` — connected and pulling from your database
   - `FEED · SUPABASE UNREACHABLE` — keys set but the request failed, so
     it's quietly falling back to the local copy

### Content model

Content lives in `works`, with `people` (bylines) and `terms`
(categories + tags) attached via join tables (`work_creators`,
`work_terms`). Placement on the page — hero, front-page duo, analysis
desk, op-ed slot, "the frequency" zine row, trending sidebar — is
driven entirely by a work's `featured`/`pinned` flags, its
`editorial_weight`, and which tags it carries (`front-page`, `desk`,
`op-ed`, `frequency`, `trending`). See `renderFeed()` in `index.html`
for the exact assignment logic.

Writes aren't exposed to the anon role by design — publish content via
the Supabase dashboard, a service-role key, or your own admin tooling.

## Notes

- "The Wall" (community forum threads) and the newsletter signup are
  currently client-side only (`localStorage` / no-op submit) — wire
  them up to real endpoints when you're ready.
- No build tooling, no dependencies to install — just static HTML/CSS/JS
  plus the Supabase JS client loaded from a CDN.

## License

MIT — see [LICENSE](LICENSE).
