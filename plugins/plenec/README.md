# Plenec for Claude Code

Plenec is your company brain. This plugin connects Claude Code to it, so a coding
session can read what the team already decided and write back what it learns.

## What you can do with it

- **Ask why it's built this way.** Search Architecture Decision Records and knowledge
  items in your workspace, and get grounded, cited answers instead of guesses.
- **File and resolve bugs** without leaving the terminal — including the root cause,
  which is embedded so future similar bugs match against it.
- **Track features and tasks.** Look up a short key like `ATR-T88`, see what's
  waiting on you across every workspace, or get a project at a glance.
- **Capture what you learned** as a knowledge page. Decisions, requirements, and
  action items are extracted and linked to the right feature automatically.

## Install

```
/plugin marketplace add atroo/claude-plugins
/plugin install plenec@atroo
```

Installing the plugin registers the Plenec MCP server for you — there is no separate
`claude mcp add` step. Sign in once:

```
claude mcp login plenec
```

or run `/mcp` inside a session and pick `plenec`. Your browser opens, you sign in at
login.atroo.de, and Claude Code stores the session. No API key or token to copy.

On a machine with no browser (SSH, a headless Linux box), add `--no-browser` and paste
the redirect URL back at the prompt.

You need a Plenec account. <!-- TODO: link the signup page here -->

<!--
Why .mcp.json carries an `oauth` block.

mcp.plenec.com is the resource server; https://login.atroo.de (Zitadel) is the
authorization server, and the protected-resource metadata correctly says so. Zitadel
has no dynamic client registration (zitadel/zitadel#9810), so a client that tries to
register its own credentials stops at "Incompatible auth server". Plenec therefore
uses one pre-registered PUBLIC client, and the plugin pins it:

  clientId      379123512457038559 — a public client: PKCE, no secret, and
                /oauth/register hands the same id to anyone who asks. Safe in a
                public repository; that is what a public client is for.
  callbackPort  8765 — Claude Code otherwise picks a random port, and Zitadel
                exact-matches redirect URIs. http://localhost:8765/callback must
                stay registered on that client, or every sign-in fails with a
                redirect URI mismatch.

Changing the port here means changing it in Zitadel too. On Claude Code v2.1.229
only, the callback was sent as http://127.0.0.1:PORT/callback — upgrade, or register
that form as well.

No scopes are pinned: without an authServerMetadataUrl override, Claude Code takes
them from the protected-resource metadata, which lists exactly openid, profile,
email and offline_access.
-->

## Getting started

Ask Claude what workspaces you have:

> Which Plenec workspaces can I see?

Then anything grounded in your team's history:

> Why did we pick Neo4j for the knowledge graph?
>
> What's waiting on me right now?
>
> File a bug: the Safari login callback drops the session cookie.

## Binding a repository to a workspace

If a repository always belongs to one workspace, bind it once and Claude stops
asking:

```
/plenec:bind
```

That writes `.plenec.json` at the repository root:

```json
{ "workspaceId": "2bb0e82b-...", "workspaceName": "atroo" }
```

Commit it and everyone who clones the repository shares the binding. From the next
session on, Plenec tools are scoped to that workspace automatically.

A binding only narrows scope. Access is authorized on the server, so it cannot reach
a workspace you could not already reach, and the file is read as an identifier only —
nothing in it is treated as an instruction.

## Pinning a workspace

If you work in one workspace almost always, you can bind this connection to it and
skip the workspace question. Point the server URL at the workspace-scoped form:

```json
{
  "mcpServers": {
    "plenec": {
      "type": "http",
      "url": "https://mcp.plenec.com/ws/<workspaceId>/mcp"
    }
  }
}
```

Tools then take no `workspaceId` argument.

## Specifying what to build

Two structured documents, one level apart. A **PRD** says what one capability must do
and why; its requirements become that feature's ratified specification, and what a
plan is later measured against. A **VISION** says what the product those capabilities
belong to is for; its outcomes become what the roadmap is judged against. A workspace
usually runs one product, but it can hold several — Claude asks which one a vision is
about rather than guessing.

> Write a PRD for the bulk export feature.
>
> Help me write our product vision.

Claude guides the conversation section by section, asking rather than filling gaps —
and it will tell you when a measure or an outcome is missing instead of inventing a
plausible one. Structure carries meaning here: each section is filed differently
against the capability or the product, so an outcome buried in background never
becomes something anyone is measured against. Your own headings and language are fine
— they are read and understood, not matched against a list.

Open questions are recorded as blocking: a capability with unanswered ones does not
pass its readiness gate. That is deliberate, and it is why a rhetorical question does
not belong in that section.

## Planning before you build

Ask Claude to plan a feature and it works a loop instead of guessing: it reads what
is already known about the capability, pulls the **engineering practices that govern
the work** — with their rationale, and the anti-patterns for the areas it touches —
and only then drafts. You judge the approach. The agreed plan is stored against the
feature and reviewed against those same practices, so gaps surface while they are
still a paragraph rather than a pull request.

> Plan the Safari cookie fix against our practices.

Findings come back as **VIOLATED** (the plan does something a practice forbids) or
**UNDERSPECIFIED** (a practice governs this, but the plan does not say enough to
tell). The second is the common one, and usually the fix is stating reasoning you
already had.

## Reviewing against your team's decisions

The plugin ships a `plenec-reviewer` subagent. Point it at work you just finished:

> Review this against the plan and our ADRs.

It reads the diff, checks it against the plan it was meant to follow, then searches
the workspace for governing decisions and sorts what it finds into three classes:
**violates an accepted ADR** (cited, with the tradeoff that decision made),
**contradicts a documented practice**, and **no decision on record**. That last class
is the point — an empty search is reported as an unexamined area, never as approval.

It is read-only: it cannot write to your workspace or your files.

## What's included

Five skills that teach Claude how to use the tools well:

| Skill | Covers |
| --- | --- |
| `orienting-in-plenec` | Establishing the workspace, resolving short keys, choosing a read tool, searching before answering or planning |
| `bug-lifecycle` | What makes a report actionable, the SUSPECTED lane, why resolutions need a real root cause |
| `capturing-knowledge` | When a session is worth a page, append vs. edit vs. propose, read-before-edit, ADR status transitions |
| `planning-a-feature` | The plan-review loop: read the practices before drafting, store the plan as a PLAN page, act on VIOLATED and UNDERSPECIFIED findings |
| `prd-and-vision` | Writing a PRD for a capability and a VISION for the product: the guided conversation, section discipline, and which sections block the readiness gate |

Plus:

- **`/plenec:capture`** — review the session and write what's worth keeping to a
  knowledge page, after showing you what it proposes to capture.
- **`plenec-reviewer`** — the compliance reviewer described above.
- **`/plenec:bind`** — bind this repository to a workspace, so you are not asked
  which one every session.
- **Two hooks**, both local, both silent when they have nothing to say, and neither
  sends anything anywhere: one states the repository's workspace binding at session
  start, the other reminds Claude to resolve an entity key like `ATR-T88` properly
  rather than guessing its type.

Nothing in this plugin writes to your workspace on its own. Every capture, edit, and
status change is something you asked for.

## Support

Issues and questions: https://github.com/atroo/claude-plugins/issues
