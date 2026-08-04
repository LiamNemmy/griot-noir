-- GRIOT NOIR — seed data
-- Run after schema.sql. Mirrors LOCAL_WIRE in index.html so the live
-- Supabase feed and the offline fallback show identical content.

-- ---------------------------------------------------------------
-- people
-- ---------------------------------------------------------------
insert into people (name, slug) values
  ('Adaeze Okonkwo',    'adaeze-okonkwo'),
  ('K. Balogun',         'k-balogun'),
  ('W. Kamau',           'w-kamau'),
  ('T. Mokoena',         't-mokoena'),
  ('Griot Noir Editorial','griot-noir-editorial'),
  ('Prof. A. Diallo',    'prof-a-diallo')
on conflict (slug) do nothing;

-- ---------------------------------------------------------------
-- terms: categories
-- ---------------------------------------------------------------
insert into terms (type, slug, name) values
  ('category','africa','Africa'),
  ('category','world','World'),
  ('category','power','Power'),
  ('category','economy','Economy'),
  ('category','tech','Tech'),
  ('category','culture','Culture'),
  ('category','opinion','Opinion')
on conflict (type, slug) do nothing;

-- ---------------------------------------------------------------
-- terms: tags
-- ---------------------------------------------------------------
insert into terms (type, slug, name) values
  ('tag','front-page','Front Page'),
  ('tag','investigation','Investigation'),
  ('tag','desk','Desk'),
  ('tag','op-ed','Op-Ed'),
  ('tag','frequency','Frequency'),
  ('tag','trending','Trending')
on conflict (type, slug) do nothing;

-- ---------------------------------------------------------------
-- works
-- ---------------------------------------------------------------
insert into works (slug, title, subtitle, summary, type, status, featured, pinned, editorial_weight, published_at, image_url, image_alt) values
  ('lagos-after-dark', 'LAGOS AFTER DARK: THE BLACKOUT ECONOMY',
    'Six months inside the diesel economy',
    'The grid fails, the generators roar, and somebody gets paid. We followed the diesel money through six months, three substations and one very quiet ministry — into the city that refuses to sleep, because sleep costs fuel.',
    'article','published', true, true, 100, '2026-08-04T05:00:00Z',
    'https://image.qwenlm.ai/public_source/d06c5f8d-358d-4121-a716-309fc0ab4573/186d55f54-5ec8-4d91-9096-002789004325.png',
    'Lagos street at night in the rain with neon signs and danfo buses'),

  ('nairobi-silicon-savannah-villain-arc', 'NAIROBI''S SILICON SAVANNAH ENTERS ITS VILLAIN ARC',
    null,
    'Layoffs, land grabs and a unicorn that stopped answering emails. The founders are still shipping — but the dream got a term sheet.',
    'article','published', true, false, 90, '2026-08-04T04:40:00Z',
    'https://image.qwenlm.ai/public_source/d06c5f8d-358d-4121-a716-309fc0ab4573/149fa6a40-e79e-4a22-bf4f-191b406eb000.png',
    'Developers at night in a Nairobi tech hub with a mural wall'),

  ('mural-wars-joburg', 'THE MURAL WARS: WHO OWNS JOBURG''S WALLS?',
    null,
    'Developers paint over memory; writers paint it back. A walking tour of the city''s loudest argument, block by block.',
    'article','published', true, false, 85, '2026-08-04T04:20:00Z',
    'https://image.qwenlm.ai/public_source/d06c5f8d-358d-4121-a716-309fc0ab4573/1098a627d-0cec-4ef7-a416-0a1035e3ca1d.png',
    'Protest mural in Johannesburg with raised fist silhouette'),

  ('sahel-fallout', 'SAHEL FALLOUT: WHAT THE COUP BELT MEANS FOR YOUR PORTFOLIO',
    null,
    'Uranium, gold, corridors, proxies. A map-driven briefing on the belt that keeps redrawing itself.',
    'essay','published', false, false, 75, '2026-08-04T04:00:00Z',
    'https://image.qwenlm.ai/public_source/d06c5f8d-358d-4121-a716-309fc0ab4573/19f50b58e-2f3c-4dde-921f-30f24515e681.png',
    'Military convoy in a Sahel dust storm at dusk'),

  ('port-politics', 'PORT POLITICS: THE NEW SCRAMBLE FOR AFRICA''S COASTLINES',
    null,
    'From Mombasa to Pointe-Noire, the crane is the new flag. Who signs the concessions — and who loads the ships?',
    'essay','published', false, false, 74, '2026-08-04T03:50:00Z',
    'https://image.qwenlm.ai/public_source/d06c5f8d-358d-4121-a716-309fc0ab4573/1a2701d1f-9c59-4f3f-a0b9-4af37c625634.png',
    'Container port cranes at dusk'),

  ('europe-border-theatre', 'EUROPE''S BORDER THEATRE IS A DISTRACTION. HERE ARE THE RECEIPTS.',
    null,
    'The spectacle is on the Mediterranean; the money moves through the ledger. We read both.',
    'essay','published', false, false, 73, '2026-08-04T03:40:00Z',
    'https://image.qwenlm.ai/public_source/d06c5f8d-358d-4121-a716-309fc0ab4573/1fc1235dc-bfe0-4a5f-9bee-9fee8a1db4cd.png',
    'Rainy neon street in Paris with figure holding umbrella'),

  ('diaspora-vote-op-ed', 'THE DIASPORA VOTE IS A SLEEPING GIANT',
    'DAKAR — 8 MIN — COMMENTS OPEN',
    'The diaspora vote is a sleeping giant with a remittance app and a long memory.',
    'essay','published', false, false, 70, '2026-08-04T03:30:00Z', null, null),

  ('amapiano-goes-to-jail', 'AMAPIANO GOES TO JAIL: THE SOUND THEY TRIED TO BAN',
    'SOUND ISSUE',
    'How a log drum became a public order problem in three countries and a religion in a fourth.',
    'gallery','published', false, false, 63, '2026-08-04T03:20:00Z', null, null),

  ('tracks-for-a-lagos-blackout', '14 TRACKS FOR A LAGOS BLACKOUT',
    'MIXTAPE',
    'Curated by three genset owners and one very patient neighbour.',
    'gallery','published', false, false, 62, '2026-08-04T03:10:00Z',
    'https://image.qwenlm.ai/public_source/d06c5f8d-358d-4121-a716-309fc0ab4573/14e996913-2c58-4a03-b2f5-7044b0e23783.png',
    'Saxophone player in smoky neon club'),

  ('writer-tagging-the-cfa-obituary', 'THE WRITER TAGGING THE CFA FRANC''S OBITUARY',
    'INTERVIEW',
    '"I don''t deface currency. I annotate it." A conversation from an undisclosed rooftop.',
    'gallery','published', false, false, 61, '2026-08-04T03:00:00Z', null, null),

  ('album-that-split-the-diaspora', 'THE ALBUM THAT SPLIT THE DIASPORA IN HALF',
    'REVIEW',
    'Five stars from London, one star from Lagos, and a group chat that will never recover.',
    'gallery','published', false, false, 60, '2026-08-04T02:50:00Z', null, null),

  ('accra-flooded-markets', 'Accra''s flooded markets: who ignored the 2019 warning report?',
    'AFRICA — 482 COMMENTS', null,
    'announcement','published', false, false, 55, '2026-08-04T02:40:00Z', null, null),

  ('cfa-franc-divorce-explainer', 'Explainer: the CFA franc divorce, 60 years in the making',
    'ECONOMY — 317 COMMENTS', null,
    'announcement','published', false, false, 54, '2026-08-04T02:30:00Z', null, null),

  ('afrobeats-buys-its-label', 'Afrobeats just bought its own label. Now what?',
    'CULTURE — 298 COMMENTS', null,
    'announcement','published', false, false, 53, '2026-08-04T02:20:00Z', null, null),

  ('capetown-water-mafia-mapped', 'Cape Town''s water mafia, mapped block by block',
    'INVESTIGATION — 264 COMMENTS', null,
    'announcement','published', false, false, 52, '2026-08-04T02:10:00Z', null, null),

  ('midnight-train-sahel', 'The quiet return of the midnight train across the Sahel',
    'WORLD — 201 COMMENTS', null,
    'announcement','published', false, false, 51, '2026-08-04T02:00:00Z', null, null)
on conflict (slug) do nothing;

-- ---------------------------------------------------------------
-- work_creators (byline order preserved via "position")
-- ---------------------------------------------------------------
insert into work_creators (work_id, person_id, role, "position")
select w.id, p.id, x.role, x.pos
from (values
  ('lagos-after-dark', 'adaeze-okonkwo', 'Writer', 0),
  ('lagos-after-dark', 'k-balogun', 'Photographer', 1),
  ('nairobi-silicon-savannah-villain-arc', 'w-kamau', 'Writer', 0),
  ('mural-wars-joburg', 't-mokoena', 'Writer', 0),
  ('sahel-fallout', 'griot-noir-editorial', 'Editor', 0),
  ('port-politics', 'griot-noir-editorial', 'Editor', 0),
  ('europe-border-theatre', 'griot-noir-editorial', 'Editor', 0),
  ('diaspora-vote-op-ed', 'prof-a-diallo', 'Contributor', 0),
  ('amapiano-goes-to-jail', 'griot-noir-editorial', 'Editor', 0),
  ('tracks-for-a-lagos-blackout', 'griot-noir-editorial', 'Editor', 0),
  ('writer-tagging-the-cfa-obituary', 'griot-noir-editorial', 'Editor', 0),
  ('album-that-split-the-diaspora', 'griot-noir-editorial', 'Editor', 0),
  ('accra-flooded-markets', 'griot-noir-editorial', 'Editor', 0),
  ('cfa-franc-divorce-explainer', 'griot-noir-editorial', 'Editor', 0),
  ('afrobeats-buys-its-label', 'griot-noir-editorial', 'Editor', 0),
  ('capetown-water-mafia-mapped', 'griot-noir-editorial', 'Editor', 0),
  ('midnight-train-sahel', 'griot-noir-editorial', 'Editor', 0)
) as x(work_slug, person_slug, role, pos)
join works w on w.slug = x.work_slug
join people p on p.slug = x.person_slug
on conflict (work_id, person_id, role) do nothing;

-- ---------------------------------------------------------------
-- work_terms (categories + tags per work)
-- ---------------------------------------------------------------
insert into work_terms (work_id, term_id)
select w.id, t.id
from (values
  ('lagos-after-dark', 'category', 'africa'),
  ('lagos-after-dark', 'tag', 'front-page'),
  ('lagos-after-dark', 'tag', 'investigation'),

  ('nairobi-silicon-savannah-villain-arc', 'category', 'tech'),
  ('nairobi-silicon-savannah-villain-arc', 'tag', 'front-page'),

  ('mural-wars-joburg', 'category', 'culture'),
  ('mural-wars-joburg', 'tag', 'front-page'),

  ('sahel-fallout', 'category', 'power'),
  ('sahel-fallout', 'tag', 'desk'),

  ('port-politics', 'category', 'economy'),
  ('port-politics', 'tag', 'desk'),

  ('europe-border-theatre', 'category', 'world'),
  ('europe-border-theatre', 'tag', 'desk'),

  ('diaspora-vote-op-ed', 'category', 'opinion'),
  ('diaspora-vote-op-ed', 'tag', 'op-ed'),

  ('amapiano-goes-to-jail', 'category', 'culture'),
  ('amapiano-goes-to-jail', 'tag', 'frequency'),

  ('tracks-for-a-lagos-blackout', 'category', 'culture'),
  ('tracks-for-a-lagos-blackout', 'tag', 'frequency'),

  ('writer-tagging-the-cfa-obituary', 'category', 'culture'),
  ('writer-tagging-the-cfa-obituary', 'tag', 'frequency'),

  ('album-that-split-the-diaspora', 'category', 'culture'),
  ('album-that-split-the-diaspora', 'tag', 'frequency'),

  ('accra-flooded-markets', 'category', 'africa'),
  ('accra-flooded-markets', 'tag', 'trending'),

  ('cfa-franc-divorce-explainer', 'category', 'economy'),
  ('cfa-franc-divorce-explainer', 'tag', 'trending'),

  ('afrobeats-buys-its-label', 'category', 'culture'),
  ('afrobeats-buys-its-label', 'tag', 'trending'),

  ('capetown-water-mafia-mapped', 'category', 'africa'),
  ('capetown-water-mafia-mapped', 'tag', 'trending'),

  ('midnight-train-sahel', 'category', 'world'),
  ('midnight-train-sahel', 'tag', 'trending')
) as x(work_slug, term_type, term_slug)
join works w on w.slug = x.work_slug
join terms t on t.type = x.term_type and t.slug = x.term_slug
on conflict (work_id, term_id) do nothing;
