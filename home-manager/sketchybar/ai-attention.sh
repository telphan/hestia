# Tracks Claude Code and Codex sessions that are waiting on you, and reports
# plan usage for the SketchyBar AI widget.
#
#   ai-attention hook claude|codex        Claude Code / Codex hook (JSON on stdin)
#   ai-attention focus [claude|codex|ID]  Focus a waiting window and clear it
#   ai-attention clear-focused            Clear whatever window is focused
#   ai-attention status                   JSON for the bar

state="${XDG_STATE_HOME:-$HOME/.local/state}/ai-attention"
pending="$state/pending"
mkdir -p "$pending"

refresh_bar() {
  sketchybar --trigger ai_attention_change >/dev/null 2>&1 || true
}

# The AeroSpace window of the terminal running PID (default: our caller). When
# that terminal owns several windows, prefer the one whose title contains the hint.
find_window() {
  local hint=$1 pid=${2:-$PPID} ancestors=" "
  while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
    ancestors+="$pid "
    pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
  done
  aerospace list-windows --all --json --format '%{window-id} %{app-pid} %{window-title}' |
    jq -r --arg ancestors "$ancestors" --arg hint "$hint" '
      map(select(.["app-pid"] as $pid | $ancestors | contains(" \($pid) ")))
      | map(select($hint != "" and (.["window-title"] | contains($hint)))) + .
      | .[0]["window-id"] // empty'
}

clear_entry() {
  terminal-notifier -remove "ai-attention-$1" >/dev/null 2>&1 || true
  rm -f "$pending/$1.json"
}

clear_window() {
  local file
  for file in "$pending"/*.json; do
    [ -e "$file" ] || continue
    if [ "$(jq -r .window "$file")" = "$1" ]; then
      clear_entry "$(basename "$file" .json)"
    fi
  done
  refresh_bar
}

# mark TOOL ID HINT TITLE MESSAGE
mark() {
  local window focused
  window=$(find_window "$3")
  [ -n "$window" ] || return 0
  focused=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null || true)
  [ "$window" != "$focused" ] || return 0

  jq -n --arg tool "$1" --argjson window "$window" '{tool: $tool, window: $window}' >"$pending/$1-$2.json"
  terminal-notifier -title "$4" -message "$5" -sound Glass \
    -group "ai-attention-$1-$2" -execute "$0 focus $window" >/dev/null
  refresh_bar
}

# Claude Code and Codex send hook input with the same fields.
hook() {
  local tool=$1 input session title
  input=$(cat)
  session=$(jq -r .session_id <<<"$input")

  case "$(jq -r .hook_event_name <<<"$input")" in
    UserPromptSubmit)
      clear_entry "$tool-$session"
      refresh_bar
      ;;
    Stop | Notification | PermissionRequest)
      # Claude Code titles the terminal window with the session's ai-title.
      title=$(grep -F '"type":"ai-title"' "$(jq -r .transcript_path <<<"$input")" 2>/dev/null | tail -1 | jq -r .aiTitle || true)
      [ -n "$title" ] || title=$(basename "$(jq -r .cwd <<<"$input")")
      mark "$tool" "$session" "$title" "$([ "$tool" = claude ] && echo "Claude Code" || echo Codex) · $title" \
        "$(jq -r '
          .message
          // (.tool_name | values | "Wants to use \(.)")
          // (.last_assistant_message | values | .[0:120])
          // "Finished — waiting for you"' <<<"$input")"
      ;;
  esac
}

# The window of the oldest running session. Claude Code titles its window with
# the session name it records in ~/.claude/sessions (launchers carry a parkedJobId).
oldest_window() {
  local names pid
  if [ "$1" = claude ]; then
    names=$(jq -s 'map(select(.parkedJobId == null and .name != null)) | sort_by(.startedAt) | map(.name)' \
      "$HOME"/.claude/sessions/*.json 2>/dev/null || echo '[]')
    aerospace list-windows --all --json --format '%{window-id} %{window-title}' |
      jq -r --argjson names "$names" '
        . as $windows
        | first($names[] as $name | $windows[] | select(.["window-title"] | contains($name)) | .["window-id"])
        // empty'
  else
    pid=$(pgrep -o -x codex || true)
    [ -z "$pid" ] || find_window "" "$pid"
  fi
}

focus() {
  local target=${1:-} window
  case "$target" in
    "" | claude | codex)
      # The oldest waiting session, optionally for one tool.
      window=$(find "$pending" -name "${target}*.json" -exec /usr/bin/stat -f '%m %N' {} + 2>/dev/null |
        sort -n | head -1 | cut -d' ' -f2- | xargs -r jq -r .window)
      # Nothing waiting: the oldest running session of that tool.
      if [ -z "$window" ] && [ -n "$target" ]; then
        window=$(oldest_window "$target")
      fi
      ;;
    *) window=$target ;;
  esac
  [ -n "$window" ] || return 0
  aerospace focus --window-id "$window" || true
  clear_window "$window"
}

codex_usage() {
  local file line
  while read -r file; do
    line=$(grep -F '"rate_limits":{' "$file" | tail -1 || true)
    if [ -n "$line" ]; then
      jq -c '.payload.rate_limits' <<<"$line"
      return
    fi
  done < <(find "$HOME/.codex/sessions" -name '*.jsonl' -exec /usr/bin/stat -f '%m %N' {} + 2>/dev/null | sort -rn | head -20 | cut -d' ' -f2-)
  echo null
}

# Highest used percentage across a plan's windows that have not reset yet.
status() {
  local claude codex
  claude=$(cat "$state/claude-usage.json" 2>/dev/null || echo null)
  codex=$(codex_usage)
  jq -n --argjson claude "$claude" --argjson codex "$codex" --slurpfile pending <(cat "$pending"/*.json 2>/dev/null) '
    def iso: sub("\\.[0-9]+"; "") | fromdateiso8601;
    {
      claude: ([$claude.five_hour, $claude.seven_day]
        | map(select(.used_percentage != null and (.resets_at == null or (.resets_at | iso) > now)) | .used_percentage)
        | max),
      codex: ([$codex.primary, $codex.secondary]
        | map(select(. != null and .resets_at > now) | .used_percent)
        | max),
      pending: ($pending | group_by(.tool) | map({key: .[0].tool, value: length}) | from_entries)
    }'
}

case "${1:-}" in
  hook) hook "${2:?claude or codex}" ;;
  focus) focus "${2:-}" ;;
  clear-focused) clear_window "$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null || true)" ;;
  status) status ;;
  *) echo "usage: ai-attention hook|focus|clear-focused|status" >&2; exit 2 ;;
esac
