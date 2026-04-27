"""Claude Code session enumerator / previewer for the `ccr` zsh picker.

No args  → list mode: emits one tab-separated row per session on stdout,
           newest first, with columns: time, cwd, uuid, label.
One arg  → preview mode: given a session UUID, print a human-readable
           summary (title + latest prompt + first ~18 messages).

Invoked from home-manager/shell.nix via its nix store path.
"""

import json
import re
import sys
import time
from pathlib import Path


def extract_text(msg):
    if not isinstance(msg, dict):
        return None
    c = msg.get("content")
    if isinstance(c, list):
        for x in c:
            if isinstance(x, dict) and x.get("type") == "text":
                return x.get("text")
        return None
    return c if isinstance(c, str) else None


def clean(s):
    return re.sub(r"<[^>]+>[^<]*</[^>]+>\s*", "", s).strip()


def scan(path):
    """Return (cwd, custom_title, last_prompt, first_user) for a session file."""
    cwd = title = last_prompt = first_user = None
    try:
        f = path.open()
    except OSError:
        return None
    with f:
        for line in f:
            try:
                d = json.loads(line)
            except Exception:
                continue
            t = d.get("type")
            if cwd is None and d.get("cwd"):
                cwd = d["cwd"]
            if t == "custom-title" and d.get("customTitle"):
                title = d["customTitle"]
            elif t == "last-prompt" and d.get("lastPrompt"):
                last_prompt = d["lastPrompt"]
            elif first_user is None and t == "user" and not d.get("isMeta"):
                txt = extract_text(d.get("message"))
                if isinstance(txt, str):
                    s = clean(txt)
                    if s and not s.startswith("Caveat:"):
                        first_user = s.splitlines()[0]
    return cwd, title, last_prompt, first_user


projects = Path.home() / ".claude" / "projects"

if len(sys.argv) > 1:
    uuid = sys.argv[1]
    matches = list(projects.glob(f"*/{uuid}.jsonl"))
    if not matches:
        print("(session not found)")
        sys.exit(0)
    j = matches[0]
    info = scan(j)
    if info:
        _, title, last_prompt, _ = info
        if title:
            print(f"title:  {title}")
        if last_prompt:
            print(f"latest: {last_prompt.splitlines()[0][:300]}")
        if title or last_prompt:
            print()
    shown = 0
    for line in j.open():
        if shown >= 18:
            break
        try:
            d = json.loads(line)
        except Exception:
            continue
        t = d.get("type")
        if t not in ("user", "assistant") or d.get("isMeta"):
            continue
        txt = extract_text(d.get("message"))
        if not isinstance(txt, str):
            continue
        txt = clean(txt)
        if not txt:
            continue
        prefix = "> " if t == "user" else "  "
        for row in txt.splitlines()[:8]:
            print(prefix + row[:200])
        print()
        shown += 1
    sys.exit(0)

rows = []
for j in projects.glob("*/*.jsonl"):
    try:
        st = j.stat()
    except OSError:
        continue
    info = scan(j)
    if not info:
        continue
    cwd, title, last_prompt, first_user = info
    if not cwd:
        continue
    if title and last_prompt:
        label = f"{title}  ·  {last_prompt.splitlines()[0][:80]}"
    elif title:
        label = title
    elif last_prompt:
        label = last_prompt.splitlines()[0][:120]
    elif first_user:
        label = first_user[:120]
    else:
        label = "(no prompt)"
    rows.append((st.st_mtime, cwd, j.stem, label))

rows.sort(reverse=True)
for mtime, cwd, uuid, label in rows:
    ts = time.strftime("%Y-%m-%d %H:%M", time.localtime(mtime))
    print(f"{ts}\t{cwd}\t{uuid}\t{label}")
