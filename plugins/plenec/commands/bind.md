---
description: Bind this repository to a Plenec workspace so it stops asking which one
---

Bind the current repository to a Plenec workspace.

1. Call `list_workspaces`. If its `pinned` field is non-null this connection is
   already bound to a workspace by URL — say so and stop; a file would be redundant.

2. Present the workspace names and ask which one this repository belongs to. Do not
   pick one yourself, and do not infer it from the repository or directory name.

3. Write `.plenec.json` at the repository root with exactly these two fields:

   ```json
   {
     "workspaceId": "<the id they chose>",
     "workspaceName": "<its name>"
   }
   ```

   If the file already exists, show the user the current binding and confirm before
   replacing it.

4. Tell them the binding takes effect at the start of the next session, and that
   committing the file shares it with everyone who clones the repository.

The binding only narrows scope — access is still authorized server-side, so it
cannot reach a workspace the user could not already reach.
