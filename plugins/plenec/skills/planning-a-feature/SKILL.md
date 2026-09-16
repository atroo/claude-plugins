---
name: planning-a-feature
description: The plan-review loop — read a capability, pull the engineering practices that govern the work before drafting, get human judgement on the approach, then store the plan as a PLAN page and have it judged against the workspace's practices. Use before implementing anything non-trivial, and whenever a plan needs reviewing, refining, or re-checking.
---

# Planning a feature

A plan reviews intent, and intent is the cheapest thing to change. Work through this
loop before writing code — not because the review is a gate, but because reading the
rules first changes what gets written.

## 1. Read the capability

`search_features` to find it by name, then `get_feature_context` for what is already
known: requirements, settled decisions, open questions, existing bugs, readiness.
`search_knowledge` and `search_adrs` for prior art in the same area.

Open questions and unsettled decisions are planning input, not noise. A plan that
silently resolves an open question is making a decision nobody agreed to.

If the feature has a **PRD**, that is the requirement set your plan will be measured
against: once both exist, requirement-versus-plan coverage is computed, and a
requirement no step addresses shows up as a gap. Read it before drafting rather than
rediscovering its requirements. A null coverage result means there was nothing to
compare, not that coverage is zero. Writing or extending the PRD itself is a different
job — see `prd-and-vision`.

## 2. Read the practices, then draft

Call `get_practices_for_feature` **before** drafting:

- `work` — what you are about to build or change, a sentence or two
- `technologies` — e.g. `["Neo4j", "React"]`
- `domains` — from `frontend`, `backend`, `api`, `database`, `infrastructure`,
  `security`, `testing`, `devops`, `architecture`

It returns each practice with its **rationale**, not just its title, and always
includes the anti-patterns for the domains you name — those are precisely the ones a
plan never thinks to mention. A practice you understand is one you can apply to a
case its author never anticipated.

Then draft the plan **in the conversation**. Do not create a page yet: a page is what
gets judged, and there is no point judging a draft the human is about to reshape.

## 3. Get human judgement on the approach

Scope, sequencing, and whether the work is worth doing at all are not machine-
judgeable. Wait for a decision before storing anything.

## 4. Store the plan — which is what makes it judgeable

`create_page` with `type: 'PLAN'` and the `featureId`, then `review_plan` with the
returned page id. These are one action, not two: the review reads the stored page.

**Set `type: 'PLAN'` explicitly.** The classifier never infers it — PLAN is
deliberately excluded from the classifiable types, so only an explicit caller can set
it. This matters more than a mislabel: a plan CONSUMES practices and is never a
source of them, so it is excluded from practice extraction and library-candidate
proposal. File it as HOWTO or EXPLANATION and one feature's implementation notes get
mined into the workspace's practice library, becoming standards that later plans are
judged against.

**Pass the `featureId`.** Without it the plan is still reviewed, but nothing connects
it to the capability it implements and it does not count toward that feature's
readiness.

A page with less than ~50 characters of body is refused with "too little content to
review" — write the plan before calling.

## What a plan must contain

**Record the reasoning, not just the steps.** Why this approach; which alternatives
you considered and why you rejected them; which constraints forced the shape. The
steps are recoverable from the diff afterwards — the reasoning exists only in this
session, and it is what the plan is judged on. A plan of bare steps comes back almost
entirely UNDERSPECIFIED.

**A rejected alternative is your strongest evidence.** "Considered stamping
`organizationId` on the project, rejected because projects move workspace" proves the
plan already knows the practice. Nothing else demonstrates compliance as cheaply.

**Never invent a rationale you do not have.** If a step has no stated reason, leave it
without one. An absent rationale is a real signal; a fabricated one destroys that
signal and survives into the graph.

## 5. Read the verdicts properly

`review_plan` returns only the **actionable** findings, and there are two kinds:

- **VIOLATED** — the plan does something a practice forbids, or omits something it
  requires where the omission is the violation. Change the plan, or state explicitly
  why you are accepting it. Never leave it silent.
- **UNDERSPECIFIED** — a practice governs this work but the plan does not say enough
  to tell whether it is followed. This is the most common finding, and usually the
  fix is to state reasoning you already have, not to redesign.

Two more verdicts exist but never appear in `findings` — UPHELD and NOT_APPLICABLE.
They are the denominator, and they are why the next rule matters.

**Always report `practicesConsidered`.** "No findings from 14 practices considered"
is a claim. "No findings from 0 considered" is not — it means nothing in the library
was in scope, and the clean result says nothing at all. A non-zero `pending` means
the run did not finish and those practices were never judged. `complianceScore` is
`null` when nothing applicable was judged; do not report a null score as a pass.

The plan is judged against **its own page's workspace** practice library, not the one
you happen to be scoped to — so a plan stored in the wrong workspace is judged
against the wrong rules.

## 6. Refine, and know when to stop

Fix findings with `edit_page`, then run `review_plan` again.

**An edit invalidates the review.** `get_plan_review` reports `stale: true` after the
page changes — re-run `review_plan` rather than citing the old result. It also
reports `reviewed`, and says the plan has no review yet rather than erroring.

**Stop looping.** If two consecutive reviews return the same findings, the plan is
not going to converge on its own. Bring the findings to the human instead of editing
again.

A clean plan review is not a review of the code that follows. It catches what is
cheapest to change, and nothing more.
