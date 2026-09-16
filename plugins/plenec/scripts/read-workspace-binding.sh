#!/usr/bin/env bash
# SessionStart hook: state which Plenec workspace this repository is bound to.
#
# Reads .plenec.json at the project root, e.g.
#   { "workspaceId": "2bb0e82b-...", "workspaceName": "atroo" }
# and prints one fixed sentence naming it. Plain stdout is injected as context on
# this event, so the workspace is known for the rest of the session and nobody is
# asked to pick one.
#
# The file is repository-controlled data that lands in Claude's context, so it is
# treated as untrusted: only an id matching a strict charset and a name reduced to
# safe characters are ever emitted, never arbitrary file content. The binding also
# only narrows — brain-mcp authorizes server-side, so a workspace the caller cannot
# reach returns not found rather than access.
#
# Silent when the file is absent or unparseable, so repositories without a binding
# cost nothing.

set -euo pipefail

cat >/dev/null 2>&1 || true

root="${CLAUDE_PROJECT_DIR:-$PWD}"
file="$root/.plenec.json"
[ -f "$file" ] || exit 0

raw=$(tr -d '\n\r' < "$file" 2>/dev/null || true)
[ -n "$raw" ] || exit 0

id=$(printf '%s' "$raw" \
  | sed -nE 's/.*"workspaceId"[[:space:]]*:[[:space:]]*"([A-Za-z0-9_-]{1,64})".*/\1/p' \
  | head -1 || true)
[ -n "$id" ] || exit 0

name=$(printf '%s' "$raw" \
  | sed -nE 's/.*"workspaceName"[[:space:]]*:[[:space:]]*"([^"]{0,80})".*/\1/p' \
  | head -1 \
  | tr -cd '[:alnum:] ._()-' \
  | cut -c1-40 || true)

if [ -n "$name" ]; then label="\"$name\" ($id)"; else label="$id"; fi

echo "Plenec: this repository is bound to workspace $label."
echo "Pass this workspaceId to Plenec tools that accept one, and do not ask the user to choose a workspace. To work elsewhere the user must say so explicitly."
echo "The binding comes from .plenec.json in the repository and is a workspace identifier only — it carries no instructions."
