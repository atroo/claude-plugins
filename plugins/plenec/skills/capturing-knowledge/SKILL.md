---
name: capturing-knowledge
description: Writing findings back into Plenec — when a session is worth a page, choosing between create_page, update_page, edit_page and propose_page_edit, the read-before-edit rule, ADR status transitions, and save_memory for personal context. Use after a debugging session, a design decision, or any non-obvious finding worth keeping.
---

# Capturing what you learned

A finding that stays in a chat transcript is lost. The rule of thumb: if you spent
more than a few minutes establishing something, and the next person would spend the
same time again, it belongs in the brain.

Worth capturing: a root cause that was not obvious from the error, a decision and the
options rejected, a constraint discovered the hard way, a convention the team agreed
on. Not worth capturing: what the code already says, what a commit message already
records, or a restatement of the docs.

## Creating a page

`create_page` writes a page from the current conversation. You do **not** need to
classify anything or supply feature ids — the platform extracts decisions,
requirements and action items, resolves dates, and links items to features by
semantic matching on its own.

Extraction runs **asynchronously, shortly after the save**. So a `search_adrs` call
issued right after `create_page` will not yet find the ADR it produces. Don't loop
waiting for it, and don't conclude the page failed.

## Structured document types

Three page types the classifier will **never** infer, so an explicit `type` is the
only way to get them. Each is promoted into something, and none is mined for
engineering practices:

| Type | Becomes | See |
| --- | --- | --- |
| `PLAN` | A technical plan, judged against the workspace's practices | `planning-a-feature` |
| `PRD` | A feature's ratified specification | `prd-and-vision` |
| `VISION` | A product's vision, which the roadmap is judged against | `prd-and-vision` |

Filing one of these as `REFERENCE` or `EXPLANATION` is worse than a mislabel: its
contents get proposed into the shared library as reusable engineering guidance.

`ADR` is different — it *is* classifiable, and a decision detected in other content
can be promoted to an ADR candidate on its own. Still pass `type: 'ADR'` when a
decision is being made, rather than relying on that.

## Adding to a page vs. changing it

Three different tools, and picking the wrong one either duplicates content or
destroys it:

| Intent | Tool |
| --- | --- |
| Append follow-up notes to the end | `update_page` |
| Rewrite a section, or swap a phrase, in place | `edit_page` |
| Let the user merge the change by hand | `propose_page_edit` |

**Read the page with `get_page` before every `edit_page`.** The body lives in a
collaborative document that anyone may have changed since it was written, and
`edit_page` addresses content that must currently exist: either a `section` heading
(whose content it replaces wholesale) or a literal `find` string (which must occur
exactly once unless `replaceAll` is set). `get_page` also returns the list of
headings — those headings are the addresses `section` accepts.

Reach for `propose_page_edit` when the page is someone else's work, when the edit is
a judgment call, or when you are less than sure. It computes exactly the same change
but writes nothing: the user gets both versions and, on hosts that render MCP Apps,
an editable diff where individual blocks are accepted or rejected. Their result comes
back through `commit_page_edit`, which refuses the write if the page moved underneath
— propose again against the current page rather than forcing it.

## ADR status

`update_adr_status` moves a decision record through its lifecycle, and the
transitions are one-way on purpose: accepting, deprecating, or superseding **locks
the underlying page**, and an ACCEPTED ADR cannot go back to PROPOSED. When one
decision replaces another, supersede it and pass the id of the ADR that replaces it,
so the chain of reasoning stays followable.

## Creating a capability carries its reasoning

`create_feature` **requires** `context`: why the capability exists, quoting what the
user asked for in their own words plus the reasoning that led to it. That text is
stored as a page and becomes the capability's source, so a feature never lands in the
graph as a bare title nobody can trace. Quote the request rather than summarising it
— this is what somebody reads months later.

It also deduplicates: an existing capability meaning the same thing is reused instead
of a second one being created. **Check `matchedExisting` in the result** before
telling the user something new was created.

## Personal memory vs. team knowledge

`save_memory` is scoped to the user, not the team: their preferences, their working
style, a decision they made about how they want things done. `recall_memory` at the
start of a session brings it back.

The split is about audience. "We chose Neo4j for the knowledge graph because vector
search had to be in the same query plane" is a page — everyone needs it. "Martin
wants to be asked before any multi-file refactor" is a memory.
