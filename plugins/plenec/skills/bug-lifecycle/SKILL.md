---
name: bug-lifecycle
description: Filing, triaging, and resolving bugs in Plenec — what makes a report actionable, the SUSPECTED confirmation lane, why resolve_bug needs a real root cause, and when to dismiss instead. Use when reporting a bug, working a triage queue, or closing one out after a fix.
---

# The bug lifecycle

## Filing

`create_bug` takes a `title` and a `symptom` at minimum, but a report that stops
there costs someone else an hour. Fill in what you actually observed:

- `reproSteps` — the shortest path you know that triggers it
- `expectedBehavior` / `actualBehavior` — stated separately, not as one sentence
- `workaround` — if you found one
- `severity`, `projectId` (from `list_projects`), `workspaceId`

When you hit the bug while working in a repository, you already have the best
report anyone will ever write: the failing input, the stack trace, the line. Put it
in the report rather than fixing it silently — a silent fix teaches the brain
nothing and the next occurrence starts from zero.

## Moving it along

`update_bug_status` walks a bug through triage, in-progress, and review. It
deliberately cannot reach a terminal state — closing a bug goes through
`resolve_bug` or `dismiss_bug`, both of which require you to say *why*.

Pass `expectedStatus` when you believe you know the current state; the call is
refused if someone moved it in the meantime, instead of clobbering their change.

## The SUSPECTED lane

Low-confidence captures — a bug the pipeline inferred from a Slack thread or a
meeting — land as SUSPECTED and wait for a human. Work them with
`confirm_suspected_bug`: confirming promotes to REPORTED, dismissing requires a
reason. Don't treat a SUSPECTED item as a real bug report until someone confirms it.

## Resolving means recording the cause

`resolve_bug` asks for `rootCause` and `resolutionSummary` because **the resolution
is embedded and matched against future bugs**. A resolution reading "fixed" is worse
than useless — it occupies the slot where the actual explanation would have been and
matches nothing.

Write the root cause as the mechanism, not the symptom:

> ❌ "Login was broken."
> ✅ "The session cookie was issued without SameSite=None, so Safari dropped it on
> the cross-origin callback. Set the attribute in the auth middleware."

Add `fixReference` (commit or PR) and `verificationNote` (how you know it's fixed)
when you have them.

`dismiss_bug` is for invalid, duplicate, or won't-fix — it also takes a required
reason, which becomes the audit record. Dismissing is not a lesser outcome than
resolving; misfiling a won't-fix as "resolved" poisons future matching.

## The suggestion queue

When an incident is resolved, the pipeline may suspect it also resolved an open bug
and files a suggestion instead of acting. `list_bug_resolution_suggestions` shows
what is waiting; `review_bug_resolution_suggestion` accepts (which resolves the bug
with the incident's resolution) or rejects it.

Never auto-accept a queue of these. Each one is a human judgment about whether two
descriptions of a failure are the same failure.

## Before any mutation, say what you are about to change

Every write tool here expects you to tell the user **which** entity you are changing
— by title, not by id — and to what state, *before* the call. "Resolving 'Safari
login redirect loop' (ATR-B3) as fixed" is reviewable. "Calling resolve_bug" is not.
