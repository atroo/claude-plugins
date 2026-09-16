---
name: prd-and-vision
description: Writing the two structured product documents — a PRD for one capability, and a VISION for the product its capabilities belong to. Covers the guided conversation for each, why their headings decide how content is filed, which sections block the readiness gate, and the filing traps. Use when asked to write, review, or extend a PRD, a product spec, requirements, or a product vision.
---

# PRD and vision

Two documents, one level apart:

- A **PRD** says what one capability must do and why. Its requirements become that
  feature's ratified specification.
- A **VISION** says what the product all those capabilities belong to is for. Its
  outcomes become what the roadmap is judged against. `list_products` is how you find
  the product — a workspace usually has one, but it can run several side by side.

Neither says **how** anything is built. That is a `PLAN`, and it is judged
differently — see `planning-a-feature`.

## The section discipline, and why it is not cosmetic

Both documents are filed by their **headings**. Each section's content is assigned a
role — `OUTCOME`, `REQUIREMENT`, `DECISION`, `CONSTRAINT`, `OPEN_QUESTION`,
`PRINCIPLE`, or `CONTEXT` — and that role decides what the item *becomes*.

Three consequences worth internalising:

- **Your wording and language are yours.** Headings are read and understood, not
  matched against a fixed list, so "Was es können muss", "Acceptance criteria" and
  "Requirements" all work.
- **Each section must hold one kind of thing.** A section mixing requirements with
  open questions cannot be filed correctly, and its items fall back to whatever role
  was guessed from their sentence shape.
- **Open with prose before the first heading.** That lead paragraph becomes the
  document's summary. Content before the first recognised heading gets no role, which
  is exactly what makes it usable as a summary.

An outcome written inside a background section is not recorded as an outcome, and
nothing will ever be measured against it. That is the whole reason to care about
structure here.

## Writing a PRD

Work through these areas, **asking follow-up questions rather than filling the gaps
yourself**:

1. **What this is, in one or two sentences.** Whose problem, and what do they do
   today instead? Plain prose at the very top, before any heading.
2. **Success metrics.** How will anyone know this worked? Prefer something already
   measured over something new. If the user cannot name a measure, say so plainly
   rather than inventing a plausible one.
3. **Requirements.** One statement per line, each standing on its own. Push for
   observable behaviour — "exports one file per month", not "uses a cron job". Use
   `search_features` to check whether a requirement belongs to a capability that
   already exists; if it does, it goes there instead.
4. **Non-goals and constraints.** What is deliberately out of scope — often the most
   valuable part — and what limits it must respect: volume, latency, compliance, a
   system it cannot change.
5. **Open questions.** What is genuinely unresolved, stated specifically.
6. **Decisions.** What has already been settled.

Then `create_page` with `type: 'PRD'` **and the `featureId`**. With the feature id the
page is promoted to that capability's ratified specification; without it the page is
still processed but nothing on any capability points at it.

## Writing a vision

Same method, one level up:

1. **What this product is, in two or three sentences.** Prose at the top; it becomes
   the summary.
2. **Background.** How this came about and what changed to make it worth doing now —
   context for a reader, deliberately not part of what the product is measured
   against.
3. **Outcomes.** What is true in a few years if this works. Each should be something
   you could later agree had or had not happened. Prefer a change in someone's life
   or work over a number nobody will look up. `search_features` shows what the product
   already does — an outcome it is plainly already achieving is worth stating
   differently, or dropping.
4. **Principles.** The rules you will decide by when a trade-off comes up: "we
   optimise for the operator, not the buyer". These are not constraints imposed on
   you; they are choices about how you will choose. **If it does not rule anything
   out, it is not a principle.**
5. **Non-goals.** What the product deliberately will not do. Usually the most useful
   section and the one people skip.
6. **Open questions.** What is genuinely unresolved at this level.

Then `create_page` with `type: 'VISION'`, and **name the product**.

Call `list_products` first. One product is the normal case, and omitting `productId`
attaches the vision to the workspace's default — right with one product, and wrong
the moment there are two. So:

- `list_products` returns one → `productId` is optional.
- `list_products` returns several → pass `productId`, and ask the user which product
  the vision is about rather than guessing from the name.

`productId` only applies to a `VISION`; it is ignored on every other type.

**Do not list features in a vision.** If the user starts enumerating them, note that
a capability belongs in its own PRD and bring the conversation back to what the
product is for.

## What not to do, in either

- **Do not invent requirements or outcomes the user has not stated.** An empty section
  is information; a fabricated one is a liability someone will later build against.
- **Do not turn a vague wish into a crisp-sounding requirement.** Ask what would make
  it observable.
- **Do not turn an aspiration into a metric the user has not chosen.**
- **Do not write how it will be built,** even when it is obvious to you.
- **Two outcomes the user believes are worth more than six that sound good.**

## Open questions block development

An `OPEN_QUESTION` on a feature blocks its readiness gate until answered. So:

- Never file a rhetorical question as an open question — it blocks real work.
- Never omit a real one to make the document look finished. That is the failure this
  section exists to prevent.

## Filing traps

- **Set the type explicitly.** `PLAN`, `PRD` and `VISION` are never inferred, and
  none of them is mined for engineering practices. Filing a PRD as `REFERENCE` or
  `EXPLANATION` is not just a mislabel: its product requirements get proposed into the
  shared library as reusable engineering guidance, which is exactly backwards.
- **Extraction is asynchronous.** The specification, the vision node, and their items
  appear shortly after the page is saved, not during the call. Do not read them back
  immediately and conclude the page failed.
- **A wrong `productId` is dropped, not refused.** An id naming a product in another
  workspace, or an archived one, is silently discarded and the vision lands on the
  default product instead — the page is still written, so nothing tells you the
  routing was ignored. Take the id from `list_products` for the workspace you are in;
  do not carry one over from another session or another workspace.
- **Coverage null is not coverage zero.** Requirement-versus-plan coverage is only
  computed when a feature has both a specification and a plan; null means there was
  nothing to compare.

## When a page is the wrong tool

`add_feature_knowledge` attaches **one** spec item to a feature deterministically —
written exactly as given, linked to the feature you name, no extraction and no
semantic matching. Its `role` is the slot: `OUTCOME`, `REQUIREMENT`, `DECISION`,
`CONSTRAINT`, `OPEN_QUESTION`, `CONTEXT`.

Prefer `create_page` for a document worth keeping whole — it captures the reasoning,
and extraction usually derives the items from it. Reach for `add_feature_knowledge`
for the handful of items that must reliably land, or to repair a page whose extraction
came back empty. Pass `sourcePageId` so the feature's Sources list points at the page
instead of at nothing.
