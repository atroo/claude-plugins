---
description: Capture what this session established as a knowledge page in Plenec
---

Review this session and capture what is worth keeping in the Plenec workspace.

1. Identify the findings that would cost the next person the same time to rediscover:
   a root cause that was not obvious from the error, a decision and the options
   rejected, a constraint discovered the hard way, a convention just agreed. Skip
   anything the code, the commit message, or the existing docs already record.

2. If there is nothing of that kind, say so plainly and stop. A page restating the
   obvious is worse than no page.

3. Otherwise, list what you propose to capture and let the user confirm or trim it
   before writing anything.

4. Establish the workspace if it is not already known (`list_workspaces` — present
   the names and ask; do not pick one).

5. Write it with `create_page`. Decisions, requirements and action items are
   extracted and linked to features automatically, so write for a human reader
   rather than trying to structure it for the extractor. Extraction runs
   asynchronously, so do not search for the resulting ADR immediately afterwards.

6. If something is about the user rather than the team — a preference, how they want
   to work — use `save_memory` instead.

Run this before compacting a long session, or at the end of one worth remembering.
