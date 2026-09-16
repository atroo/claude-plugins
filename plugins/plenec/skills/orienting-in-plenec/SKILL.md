---
name: orienting-in-plenec
description: How to find your way around a Plenec workspace before answering or planning — picking the right workspace, resolving short keys like ATR-T88, and choosing between search_knowledge, search_adrs, ask_brain, and the project/task views. Use whenever a question touches past decisions, architecture choices, team practices, project status, or an entity key.
---

# Orienting in Plenec

Plenec holds what the team already decided. Reaching for it first is the difference
between an answer grounded in the codebase's actual history and one invented from
the current file's contents.

## Always establish the workspace first

Every read and write is scoped to a workspace. There is no ambient default. Work
down this list and stop at the first that applies:

1. **The repository is bound.** If a line at the start of the session says this
   repository is bound to a Plenec workspace, use that `workspaceId` and ask
   nothing. It comes from `.plenec.json` at the repository root, which the team
   commits so everyone shares the binding. `/plenec:bind` writes it.
2. **The connector is pinned.** If `list_workspaces` returns a non-null `pinned`,
   the connector URL is already bound to one workspace — pass no `workspaceId`
   anywhere.
3. **Otherwise ask.** Call `list_workspaces`, **present the names to the user, and
   ask which one to use.** Do not pick one yourself, and do not infer it from the
   repository or directory name. Pass the chosen `workspaceId` explicitly to every
   tool that takes one, and reuse the answer for the rest of the session.

A binding only narrows: access is authorized server-side, so a workspace the user
cannot reach returns not found rather than data. If the user asks about something
that is plainly in a different workspace, say which one you are scoped to rather
than silently searching the wrong one.

## A key in the conversation is an instruction

When someone mentions a key — `ATR-T88`, `ATR-F12`, `ATR-B3` — call `resolve_key`
before anything else. It returns the type, id, title and status, which tells you
which tool comes next. The letter after the dash is the type: **F**=feature,
**T**=task, **B**=bug.

Guessing that `ATR-T88` is a task and calling `get_task` directly works until it
doesn't; `resolve_key` costs one call and never mis-routes.

## Choosing a read tool

| You want | Call |
| --- | --- |
| A grounded, cited answer to a freeform question | `ask_brain` |
| Knowledge items, insights, prior findings | `search_knowledge` |
| Why a technology or design was chosen | `search_adrs` |
| A feature by name, when you have no id | `search_features` |
| Everything about one feature — knowledge, tasks, decisions | `get_feature_context` |
| What this workspace builds, and the products in it | `list_products` |
| "How is project X going?" | `get_project_overview` |
| "What should I work on?" | `my_work` |
| Tasks by owner, status, due date | `list_tasks` |
| Full detail on one bug | `get_bug` |

Two that are easy to miss: `list_projects` is the only way to discover the project
ids that `create_bug`, `list_tasks` and `get_project_overview` take, and
`recall_memory` at the start of a session surfaces the user's own past decisions and
preferences. `list_products` plays the same role one level up — it is where a
`productId` comes from, and a product id cannot be guessed.

## Search before you answer an architecture question

Before answering *any* question about technology choices, design tradeoffs, or "why
is it built this way", run `search_adrs` and `search_knowledge` for the workspace. An
accepted ADR outranks your reasoning about the code — the code shows what was done,
the ADR shows what was decided and why, including the options that were rejected.

If the search comes back empty, say so plainly rather than presenting your own
inference as the team's position.

## Search before you plan

Before proposing an implementation plan, check whether the capability already exists:
`search_features` for the domain, then `get_feature_context` on anything close. A
feature already carries its knowledge items, its open tasks, and the decisions behind
it — that is the plan's starting point, not a blank page.
