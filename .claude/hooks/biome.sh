#!/bin/sh
# PostToolUse hook: format + lint-fix the file Claude just edited with Biome.
# Only reports back (exit 2) when a diagnostic survives --write, so Claude
# isn't interrupted for pure formatting changes.
set -eu

f=$(jq -r '.tool_input.file_path // empty')
[ -z "$f" ] && exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0

case "$f" in
  *.js|*.jsx|*.ts|*.tsx|*.cjs|*.mjs|*.json|*.jsonc|*.css) ;;
  *) exit 0 ;;
esac

[ -f "$f" ] || exit 0

if ! out=$(pnpm exec biome check --write --no-errors-on-unmatched --files-ignore-unknown=true --colors=off "$f" 2>&1); then
  echo "$out" >&2
  exit 2
fi
