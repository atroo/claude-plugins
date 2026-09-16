#!/usr/bin/env bash
# UserPromptSubmit hook: spot Plenec entity keys in the user's message.
#
# Keys look like ATR-T88 (task), ATR-F12 (feature), ATR-B3 (bug). The letter
# after the dash is the type, and guessing it wrong routes to the wrong tool —
# so nudge toward resolve_key, which returns the type, id, title and status.
#
# Prints nothing when no key is present, so the common case costs no tokens.
# Plain stdout is injected as context on this event.

set -euo pipefail

input=$(cat)

# Matched against the whole payload rather than parsed out of JSON, to avoid a
# jq dependency on machines that do not have it. A false positive costs one
# injected line.
keys=$(printf '%s' "$input" \
  | grep -Eo '[A-Z][A-Z0-9]{1,9}-[FTB][0-9]+' \
  | sort -u \
  | head -10 \
  | tr '\n' ' ' || true)

if [ -n "${keys// /}" ]; then
  echo "Plenec entity keys mentioned: ${keys%% }"
  echo "Call resolve_key on each before acting on it — the letter after the dash is the type (F=feature, T=task, B=bug), and it determines which tool applies. Do not infer the type or the id from the key itself."
fi
