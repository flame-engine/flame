#!/usr/bin/env bash
# Reads commit metadata and PR descriptions from stdin and fails if a line
# attributes the work to an AI tool. Matching on the addresses that the tools
# use, and only on whole lines, keeps people named Claude and prose that merely
# mentions a tool from being flagged.

set -euo pipefail

trailer_addresses='noreply@anthropic\.com|claude@anthropic\.com'
trailer_addresses+='|noreply@openai\.com|codex@openai\.com'
trailer_addresses+='|cursoragent@cursor\.com|aider@aider\.chat'
trailer_addresses+='|[0-9]+\+copilot@users\.noreply\.github\.com'
trailer_addresses+='|(claude|copilot|copilot-swe-agent|cursor|devin-ai-integration'
trailer_addresses+='|gemini-code-assist|google-labs-jules|chatgpt-codex-connector)'
trailer_addresses+='\[bot\]@users\.noreply\.github\.com'

tools='claude|copilot|chatgpt|codex|gemini|cursor|windsurf|aider|devin'

trailer="^[[:space:]]*[a-z-]+:[^<]*<[^>]*(${trailer_addresses})>"
footer="^[^[:alnum:]]*(generated|created|made|written|authored|built)"
footer+="[[:space:]]+(with|by|using|in)[^[:alnum:]]*(${tools})"
session_link='claude\.ai/code/session'

if matches=$(grep -Ei -e "$trailer" -e "$footer" -e "$session_link"); then
  cat >&2 <<'EOF'
This PR contains AI attribution. Using AI tools to contribute to Flame is
perfectly fine, we just don't want the attribution in the git history.

Remove these lines from the commit messages, commit authors or PR description
(for commits, amend or rebase them and force push):

EOF
  printf '%s\n' "$matches" >&2
  exit 1
fi
