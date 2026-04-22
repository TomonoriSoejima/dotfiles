#!/usr/bin/env bash
# RTK Copilot PreToolUse hook
# Workaround for https://github.com/rtk-ai/rtk/issues/1425
# rtk hook copilot doesn't recognize "run_in_terminal" (VS Code Copilot Chat tool name)
# so we intercept it here and return deny-with-suggestion to trigger a rewrite.

input=$(cat)
tool_name=$(echo "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)

if [[ "$tool_name" == "run_in_terminal" ]]; then
  # Delegate to rtk hook copilot with the input
  result=$(echo "$input" | rtk hook copilot 2>/dev/null)

  # If rtk produced output, use it
  if [[ -n "$result" ]]; then
    echo "$result"
    exit 0
  fi

  # rtk returned nothing (PassThrough) — apply deny-with-suggestion workaround
  command=$(echo "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

  # Only rewrite if command doesn't already start with rtk
  if [[ -n "$command" && "$command" != rtk* ]]; then
    first_word=$(echo "$command" | awk '{print $1}')
    rest=$(echo "$command" | cut -d' ' -f2-)
    rtk_cmd="rtk $first_word $rest"
    python3 -c "
import json, sys
print(json.dumps({
  'hookSpecificOutput': {
    'hookEventName': 'PreToolUse',
    'permissionDecision': 'deny',
    'permissionDecisionReason': f'Use \`$rtk_cmd\` instead for 60-90% token savings (rtk)'
  }
}))
"
    exit 0
  fi
fi

# For all other tool names, delegate to rtk hook copilot
echo "$input" | rtk hook copilot 2>/dev/null
