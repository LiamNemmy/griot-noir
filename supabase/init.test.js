import { beforeEach, describe, it, expect } from 'vitest';

// Tests for supabase/init.js helpers (resolveImageUrl, mapRowFromDb)
// The original file attaches helpers to window.GRIOT_SUPABASE and uses window.supabase

beforeEach(() => {
  // Provide a DOM-like global for the script to attach to
  global.window = {};

  // Simulate missing /config.json so loadRuntimeConfig falls back to GRIOT_CONFIG
  global.fetch = async () => ({ ok: false });

  // Provide runtime config including Supabase keys and bucket
  window.GRIOT_CONFIG = { SUPABASE_URL: 'https://example.supabase.co', SUPABASE_ANON_KEY: 'anon', IMAGE_BUCKET: 'images' };

  // Provide a minimal supabase client stub with storage and realtime channel API
  window.supabase = {
    createClient: function () {
      return {
        storage: {
          from: function (bucket) {
            return {
              getPublicUrl: function (path) {
                return { data: { publicUrl: `https://cdn.example/${path}` } };
              }
            };
          }
        },
        channel: function () {
          // simple chainable stub for .on(...).subscribe()
          return {
            on: function () { return this; },
            subscribe: function () { return Promise.resolve(); }
          };
        }
      };
    }
  };
});

describe('GRIOT_SUPABASE helpers', () => {
  it('resolveImageUrl prefers storage public URL when image_path present', async () => {
    // import the script which attaches helpers to window
    await import('./init.js');
    await window.GRIOT_SUPABASE.init();

    const url = await window.resolveImageUrl({ image_path: 'cover.jpg' });
    expect(url).toBe('https://cdn.example/cover.jpg');
  });

  it('mapRowFromDb handles null input', async () => {
    await import('./init.js');
    await window.GRIOT_SUPABASE.init();
    expect(await window.mapRowFromDb(null)).toBeNull();
  });

  it('mapRowFromDb maps work_creators and sorts by position, maps terms to categories/tags, and resolves image_url', async () => {
    await import('./init.js');
    await window.GRIOT_SUPABASE.init();

    const row = {
      id: 42,
      slug: 'the-work',
      title: 'The Work',
      work_creators: [
        { position: 2, person: { name: 'Beta' }, role: 'Author' },
        { position: 1, name: 'Alpha', role: 'Composer' }
      ],
      work_terms: [
        { term: { type: 'category', name: 'Music', slug: 'music' } },
        { term: { type: 'tag', name: 'Jazz', slug: 'jazz' } }
      ],
      image_path: 'img.png',
      featured: 1,
      pinned: 0,
      editorial_weight: 3
    };

    const mapped = await window.mapRowFromDb(row);
    expect(mapped).toHaveProperty('id', 42);
    expect(mapped).toHaveProperty('slug', 'the-work');
    expect(mapped.creators).toHaveLength(2);
    // creators should be sorted by position ascending (Alpha then Beta)
    expect(mapped.creators[0].name).toBe('Alpha');
    expect(mapped.creators[1].name).toBe('Beta');

    expect(mapped.categories).toEqual(['Music']);
    expect(mapped.tags).toEqual(['Jazz']);

    expect(mapped.image_url).toBe('https://cdn.example/img.png');
  });

  it('mapRowFromDb parses creators_json when present', async () => {
    await import('./init.js');
    await window.GRIOT_SUPABASE.init();

    const row = { creators_json: JSON.stringify([{ name: 'Solo', role: 'Performer' }]) };
    const mapped = await window.mapRowFromDb(row);
    expect(mapped.creators).toEqual([{ name: 'Solo', role: 'Performer' }]);
  });
});
