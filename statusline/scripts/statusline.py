#!/usr/bin/env python3

# Claude Code StatusLine — Configurable renderer
# Reads ~/.claude/statusline.config.json for layout/section/icon preferences.
# Falls back to 3-line detailed layout if no config exists.
#
# Debug: echo '<json>' | python3 scripts/statusline.py

import json, sys, os, subprocess, re, hashlib, time as _time

# ── Config ─────────────────────────────────────────
CONFIG_PATH = os.path.expanduser("~/.claude/statusline.config.json")

DEFAULT_CONFIG = {
    "line_format": "3",
    "separator": "arrow",
    "context_style": "progress_bar",
    "icon_style": "emoji",
    "show_context": True,
    "show_rate_limits": True,
    "show_git_branch": True,
    "show_tools": True,
    "show_agents": True,
    "show_cache": True,
    "show_session": True,
    "show_reasoning": True,
    "color_style": "colorful",
}

def load_config():
    try:
        with open(CONFIG_PATH) as f:
            user = json.load(f)
        merged = {**DEFAULT_CONFIG, **user}
        return merged
    except Exception:
        return dict(DEFAULT_CONFIG)

cfg = load_config()

# ── Icon sets ──────────────────────────────────────
ICONS = {
    "emoji": {
        "folder": "📁", "branch": "", "model": "🤖",
        "context": "📊", "rate": "⏱️", "cache": "🗃️",
        "tools": "🔧", "agents": "👷", "session": "⏳",
        "idle": "💤",
    },
    "unicode": {
        "folder": "■", "branch": "⑂", "model": "◈",
        "context": "▪", "rate": "◷", "cache": "◇",
        "tools": "▸", "agents": "◆", "session": "∘",
        "idle": "·",
    },
    "minimal": {
        "folder": "", "branch": "", "model": "",
        "context": "", "rate": "", "cache": "",
        "tools": "", "agents": "", "session": "",
        "idle": "",
    },
}

icons = ICONS.get(cfg["icon_style"], ICONS["emoji"])

# ── Separator ──────────────────────────────────────
SEPARATORS = {
    "arrow": "→", "pipe": "│", "slash": "/", "dot": "·",
}

RST = "\033[0m"
DIM = "\033[2m"
SEP_CHAR = SEPARATORS.get(cfg["separator"], "→")
SEP = f" {DIM}{SEP_CHAR}{RST} "


# ── Parse input JSON ───────────────────────────────
d = json.load(sys.stdin)

def g(path, default=""):
    node = d
    for k in path.split("."):
        if isinstance(node, dict):
            node = node.get(k)
        else:
            return default
    return default if node is None else node


# ── Fields ─────────────────────────────────────────
cwd        = g("workspace.current_dir") or g("cwd", "")
model_id   = g("model.id", "unknown")
version    = g("version", "")

ws   = int(g("context_window.context_window_size", 200000))
cu   = g("context_window.current_usage")
if cu:
    itok  = int(g("context_window.current_usage.input_tokens", 0))
    cc    = int(g("context_window.current_usage.cache_creation_input_tokens", 0))
    cr    = int(g("context_window.current_usage.cache_read_input_tokens", 0))
    total = itok + cc + cr
else:
    itok = cc = cr = 0
    total = 0

pct = int(total * 100 / ws) if ws > 0 else 0

effort_level = g("effort.level", "")
r5h       = g("rate_limits.five_hour.used_percentage", "")
r7d       = g("rate_limits.seven_day.used_percentage", "")
r5h_reset = g("rate_limits.five_hour.resets_at", "")

# Cache (Anthropic only — GLM proxy reports fake cache values)
is_claude = model_id.lower().startswith("claude-")
cache_total = cc + cr if cu else 0
cache_hit_pct = (cr * 100 / cache_total) if cache_total > 0 else 0
cache_pct_str = f"{cache_hit_pct:.2f}%" if cache_hit_pct >= 99 else f"{int(cache_hit_pct)}%"


# ── Formatters ─────────────────────────────────────
def fmt_tok(n):
    if n >= 1_000_000: return f"{n/1_000_000:.1f}M"
    if n >= 1_000:     return f"{n//1_000}k"
    return str(n)

def fmt_duration(seconds):
    h, m = divmod(int(seconds), 3600)
    m2 = m // 60
    if h > 0: return f"{h}h{m2}m"
    if m2 > 0: return f"{m2}m"
    return f"{int(seconds)}s"

def fmt_bar(p, width=10):
    filled = p * width // 100
    return chr(9608) * filled + chr(9617) * (width - filled)

def fmt_reset(epoch_str):
    try:
        diff = int(float(epoch_str)) - int(_time.time())
        if diff <= 0: return ""
        h, m = divmod(diff, 3600)
        m2 = m // 60
        return f"{h}h{m2}m" if h > 0 else f"{m2}m"
    except Exception:
        return ""

def color_for(pct_val):
    p = int(pct_val)
    if p >= 85: return "\033[1;31m"
    if p >= 70: return "\033[1;33m"
    if p >= 50: return "\033[0;33m"
    return "\033[1;32m"


# ── Model name simplifier ─────────────────────────
def simplify_model(mid, ctx_size):
    s = mid.lower()
    if s.startswith("claude-"):
        s = s[7:]
    s = re.sub(r'-\d{8,}$', '', s)
    s = re.sub(r'-(\d+)$', r'.\1', s)
    if re.search(r'\[\d+[km]\]$', s):
        return s
    def fmt_ctx(n):
        if n >= 1_000_000: return f"{n//1_000_000}m"
        if n >= 1_000:     return f"{n//1_000}k"
        return str(n)
    ctx_tag = fmt_ctx(ctx_size) if ctx_size else ""
    if ctx_tag:
        s += f"[{ctx_tag}]"
    return s


# ── Session duration ───────────────────────────────
session_dur = ""
if cfg.get("show_session", True):
    try:
        session_key = hashlib.md5(cwd.encode()).hexdigest()[:12]
        session_file = f"/tmp/claude-session-{session_key}.ts"
        now = _time.time()
        try:
            with open(session_file) as f:
                start = float(f.read().strip())
            if now - start > 86400:
                start = now
                with open(session_file, 'w') as f:
                    f.write(str(now))
        except (FileNotFoundError, ValueError):
            start = now
            with open(session_file, 'w') as f:
                f.write(str(now))
        session_dur = fmt_duration(now - start)
    except Exception:
        pass


# ── Git branch ─────────────────────────────────────
git_branch = ""
if cfg.get("show_git_branch", True) and cwd:
    try:
        r = subprocess.run(
            ["git", "-C", cwd, "--no-optional-locks", "branch", "--show-current"],
            capture_output=True, text=True, timeout=2
        )
        git_branch = r.stdout.strip()
    except Exception:
        pass


# ── Active tools (process-detected) ────────────────
tool_names = []
agent_count = 0
if cfg.get("show_tools", True):
    for name, pattern in [("Seq", "sequential-thinking"), ("Ctx7", "context7"), ("ZRead", "zread")]:
        try:
            p = subprocess.run(["pgrep", "-f", pattern], capture_output=True, timeout=1)
            if p.returncode == 0: tool_names.append(name)
        except Exception: pass

if cfg.get("show_agents", True):
    try:
        p = subprocess.run(["pgrep", "-f", "claude-agent"], capture_output=True, timeout=1)
        agent_count = len(p.stdout.strip().split(b'\n')) if p.stdout.strip() else 0
    except Exception: pass


# ═══════════════════════════════════════════════════
# RENDER — Layout templates
# ═══════════════════════════════════════════════════

def render_3line():
    """Detailed 3-line layout with progress bar, icons, all sections."""
    # ── Line 1: folder (branch) → model[ctx] (effort) → session ──
    short_dir = os.path.basename(cwd) if cwd else "~"
    parts = []

    folder_part = f"{icons['folder']} \033[1;36m{short_dir}{RST}"
    if git_branch:
        folder_part += f" \033[1;35m({git_branch}){RST}"
    parts.append(folder_part)

    model_str = simplify_model(model_id, ws)
    if cfg.get("show_reasoning", True) and effort_level:
        model_str += f" ({effort_level})"
    parts.append(f"{icons['model']} \033[1;33m{model_str}{RST}")

    if session_dur:
        parts.append(f"{icons['session']} {DIM}{session_dur}{RST}")

    line1 = SEP.join(parts)

    # ── Line 2: context → cache → rate limits ──
    line2_parts = []

    # Context
    if cfg.get("show_context", True):
        style = cfg.get("context_style", "progress_bar")
        if total > 0:
            cc_col = color_for(pct)
            if style == "progress_bar":
                line2_parts.append(f"{icons['context']} {cc_col}{fmt_bar(pct)}{RST} {cc_col}{pct}%{RST} {DIM}({fmt_tok(total)}/{fmt_tok(ws)}){RST}")
            elif style == "tokens":
                line2_parts.append(f"{icons['context']} {cc_col}{pct}%{RST} {DIM}({fmt_tok(total)}/{fmt_tok(ws)}){RST}")
            else:
                line2_parts.append(f"{icons['context']} {cc_col}{pct}%{RST}")
        else:
            line2_parts.append(f"{icons['context']} {DIM}context: empty{RST}")

    # Cache
    if cfg.get("show_cache", True) and is_claude and cache_total > 0:
        cache_pct_int = int(cache_hit_pct)
        cache_color = "\033[1;32m" if cache_pct_int >= 70 else "\033[0;33m" if cache_pct_int >= 40 else "\033[1;31m"
        line2_parts.append(f"{icons['cache']} {cache_color}{cache_pct_str}{RST} {DIM}({fmt_tok(cr)}/{fmt_tok(cache_total)}){RST} cache hit")

    # Rate limits
    if cfg.get("show_rate_limits", True):
        rate_parts = []
        if r5h != "":
            c5 = color_for(r5h)
            r5h_str = f"{DIM}5h:{RST} {c5}{int(float(r5h))}%{RST}"
            if r5h_reset:
                rs = fmt_reset(r5h_reset)
                if rs:
                    r5h_str += f" {DIM}(reset {rs}){RST}"
            rate_parts.append(r5h_str)
        if r7d != "":
            c7 = color_for(r7d)
            rate_parts.append(f"{DIM}7d:{RST} {c7}{int(float(r7d))}%{RST}")
        rate_str = f" {DIM}|{RST} ".join(rate_parts) if rate_parts else f"{DIM}rate-limits: n/a{RST}"
        line2_parts.append(f"{icons['rate']} {rate_str}")

    line2 = SEP.join(line2_parts)

    # ── Line 3: tools → agents ──
    line3_parts = []
    if tool_names:
        line3_parts.append(f"{icons['tools']} {DIM}{' '.join(tool_names)}{RST}")
    if agent_count > 0:
        line3_parts.append(f"{icons['agents']} \033[1;32m{agent_count} active{RST}")
    line3 = SEP.join(line3_parts) if line3_parts else f"{icons['idle']} {DIM}idle{RST}"

    return f"{line1}\n{line2}\n{line3}"


def render_2line():
    """Balanced 2-line: location + model | metrics."""
    short_dir = os.path.basename(cwd) if cwd else "~"

    # Line 1: folder (branch) → model[ctx] (effort) ⏳ duration
    parts = []
    folder_part = f"\033[1;36m{short_dir}{RST}"
    if git_branch:
        folder_part += f" \033[1;35m({git_branch}){RST}"
    parts.append(folder_part)

    model_str = simplify_model(model_id, ws)
    if cfg.get("show_reasoning", True) and effort_level:
        model_str += f" ({effort_level})"
    parts.append(f"\033[1;33m{model_str}{RST}")
    if session_dur:
        parts.append(f"{DIM}{session_dur}{RST}")

    line1 = SEP.join(parts)

    # Line 2: ctx | cache | rate | tools
    line2_parts = []
    if cfg.get("show_context", True) and total > 0:
        cc_col = color_for(pct)
        style = cfg.get("context_style", "progress_bar")
        if style == "progress_bar":
            line2_parts.append(f"{cc_col}{fmt_bar(pct)}{RST} {cc_col}{pct}%{RST} {DIM}({fmt_tok(total)}/{fmt_tok(ws)}){RST}")
        elif style == "tokens":
            line2_parts.append(f"{cc_col}{pct}%{RST} {DIM}({fmt_tok(total)}/{fmt_tok(ws)}){RST}")
        else:
            line2_parts.append(f"{cc_col}{pct}%{RST}")

    if cfg.get("show_cache", True) and is_claude and cache_total > 0:
        cache_pct_int = int(cache_hit_pct)
        cache_color = "\033[1;32m" if cache_pct_int >= 70 else "\033[0;33m" if cache_pct_int >= 40 else "\033[1;31m"
        line2_parts.append(f"{cache_color}cache {cache_pct_str}{RST} {DIM}({fmt_tok(cr)}/{fmt_tok(cache_total)}){RST}")

    if cfg.get("show_rate_limits", True):
        rate_parts = []
        if r5h != "":
            rate_parts.append(f"{color_for(r5h)}{int(float(r5h))}%{RST}")
        if r7d != "":
            rate_parts.append(f"{color_for(r7d)}{int(float(r7d))}%{RST}")
        if rate_parts:
            line2_parts.append(f"{DIM}5h:{RST} {rate_parts[0]} {DIM}| 7d:{RST} {rate_parts[1]}" if len(rate_parts) > 1 else f"{DIM}5h:{RST} {rate_parts[0]}")

    if tool_names:
        line2_parts.append(f"{DIM}{' '.join(tool_names)}{RST}")
    if agent_count > 0:
        line2_parts.append(f"\033[1;32m{agent_count} agents{RST}")

    line2 = SEP.join(line2_parts) if line2_parts else f"{DIM}idle{RST}"
    return f"{line1}\n{line2}"


def render_1line():
    """Compact single-line: folder (branch) → model ctx% 5h% 7d%."""
    short_dir = os.path.basename(cwd) if cwd else "~"
    parts = []

    folder_part = f"\033[1;36m{short_dir}{RST}"
    if git_branch:
        folder_part += f"\033[1;35m({git_branch}){RST}"
    parts.append(folder_part)

    model_str = simplify_model(model_id, ws)
    if cfg.get("show_reasoning", True) and effort_level:
        model_str += f" ({effort_level})"
    parts.append(f"\033[1;33m{model_str}{RST}")

    if cfg.get("show_context", True) and total > 0:
        cc_col = color_for(pct)
        parts.append(f"{cc_col}{pct}%{RST}")

    if cfg.get("show_rate_limits", True):
        rate_bits = []
        if r5h != "": rate_bits.append(f"5h:{color_for(r5h)}{int(float(r5h))}%{RST}")
        if r7d != "": rate_bits.append(f"7d:{color_for(r7d)}{int(float(r7d))}%{RST}")
        if rate_bits:
            parts.append(f" {DIM}|{RST} ".join(rate_bits))

    if session_dur:
        parts.append(f"{DIM}{session_dur}{RST}")

    return SEP.join(parts)


# ── Dispatch by layout ─────────────────────────────
layout = str(cfg.get("line_format", "3"))
if layout == "1":
    print(render_1line())
elif layout == "2":
    print(render_2line())
else:
    print(render_3line())
