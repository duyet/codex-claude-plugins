#!/usr/bin/env python3
"""Generate every harness manifest and the README plugin table from marketplace.json, and lint plugins.

  python3 scripts/plugins.py sync    # rewrite generated manifests
  python3 scripts/plugins.py check   # fail on drift or broken plugins

marketplace.json is the only hand-edited manifest. Each plugin entry holds
name, displayName, description, version, category.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REGISTRY = ROOT / "marketplace.json"
REPO_URL = "https://github.com/duyet/codex-claude-plugins"
LICENSE = "MIT"
LOGO = "./assets/logo.svg"
COMPONENTS = {
    "skills": ("skills", "Skill"),
    "commands": ("commands", "Command"),
    "agents": ("agents", "Agent"),
}
FRONTMATTER = re.compile(r"\A---\n(.*?)\n---\n", re.S)
LINK = re.compile(r"\]\(([^)#\s]+)(?:#[^)]*)?\)")


def components(plugin_dir):
    found = {key: f"./{sub}/" for key, (sub, _) in COMPONENTS.items() if (plugin_dir / sub).is_dir()}
    if (plugin_dir / "hooks" / "hooks.json").is_file():
        found["hooks"] = "./hooks/hooks.json"
    if (plugin_dir / ".mcp.json").is_file():
        found["mcpServers"] = "./.mcp.json"
    return found


def capabilities(found):
    caps = [label for key, (_, label) in COMPONENTS.items() if key in found]
    caps += [label for key, label in (("hooks", "Hook"), ("mcpServers", "MCP")) if key in found]
    return caps


def plugin_manifests(entry, author):
    name = entry["name"]
    plugin_dir = ROOT / name
    found = components(plugin_dir)
    base = {
        "name": name,
        "version": entry["version"],
        "description": entry["description"],
        "author": author,
        "license": LICENSE,
    }
    interface = {
        "displayName": entry["displayName"],
        "shortDescription": entry["description"],
        "developerName": author["name"],
        "category": entry["category"],
        "capabilities": capabilities(found),
        "logo": LOGO,
        "composerIcon": LOGO,
    }
    paths = {k: v for k, v in found.items() if k != "hooks"}
    out = {
        ".claude-plugin/plugin.json": {**base, "homepage": f"{REPO_URL}/tree/master/{name}", "logo": LOGO},
        ".codex-plugin/plugin.json": {**base, **paths, "interface": interface},
        ".grok-plugin/plugin.json": {**base, "logo": LOGO, "keywords": [name], **paths},
        ".grok-build-plugin/plugin.json": {**base, "logo": LOGO, **paths, "interface": interface},
        ".cursor-plugin/plugin.json": {
            **base,
            "author": {"name": author["name"]},
            "displayName": entry["displayName"],
            "homepage": f"{REPO_URL}/tree/master/{name}",
            "repository": REPO_URL,
            "logo": LOGO,
            "category": entry["category"],
            **paths,
        },
    }
    if (plugin_dir / ".antigravity-plugin").is_dir():
        out[".antigravity-plugin/plugin.json"] = {**base, **found, "interface": interface}
    return {f"{name}/{rel}": data for rel, data in out.items()}


def marketplaces(registry):
    owner = registry["author"]
    name = registry["name"]
    plugins = registry["plugins"]
    return {
        ".claude-plugin/marketplace.json": {
            "name": name,
            "owner": owner,
            "metadata": {"description": registry["description"], "version": registry["version"]},
            "plugins": [
                {
                    "name": p["name"],
                    "source": f"./{p['name']}",
                    "description": p["description"],
                    "version": p["version"],
                    "category": p["category"],
                    "logo": f"./{p['name']}/assets/logo.svg",
                }
                for p in plugins
            ],
        },
        ".agents/plugins/marketplace.json": {
            "name": name,
            "interface": {"displayName": registry["displayName"], "logo": LOGO, "composerIcon": LOGO},
            "plugins": [
                {
                    "name": p["name"],
                    "source": {"source": "local", "path": f"./{p['name']}"},
                    "policy": {"installation": "AVAILABLE", "authentication": "ON_INSTALL"},
                    "category": p["category"],
                    "interface": {
                        "logo": f"./{p['name']}/assets/logo.svg",
                        "composerIcon": f"./{p['name']}/assets/logo.svg",
                    },
                }
                for p in plugins
            ],
        },
        ".grok-plugin/marketplace.json": {
            "name": name,
            "description": registry["description"],
            "owner": owner,
            "plugins": [
                {
                    "name": p["name"],
                    "description": p["description"],
                    "category": p["category"],
                    "source": {"type": "local", "path": f"./{p['name']}"},
                    "homepage": REPO_URL,
                    "keywords": [p["name"]],
                    "logo": "assets/logo.svg",
                    "version": p["version"],
                    "author": owner,
                }
                for p in plugins
            ],
        },
        ".cursor-plugin/marketplace.json": {
            "name": name,
            "owner": {"name": owner["name"]},
            "metadata": {"description": registry["description"]},
            "plugins": [
                {"name": p["name"], "source": p["name"], "description": p["description"]} for p in plugins
            ],
        },
    }


def readme(registry):
    text = (ROOT / "README.md").read_text()
    start, end = "<!-- plugins:start -->", "<!-- plugins:end -->"
    rows = ["| Plugin | Category | Description |", "| --- | --- | --- |"]
    rows += [f"| [{p['name']}](./{p['name']}/) | {p['category']} | {p['description']} |" for p in registry["plugins"]]
    head, _, rest = text.partition(start)
    _, _, tail = rest.partition(end)
    return f"{head}{start}\n" + "\n".join(rows) + f"\n{end}{tail}"


def generated(registry):
    out = marketplaces(registry)
    for entry in registry["plugins"]:
        out.update(plugin_manifests(entry, registry["author"]))
    files = {path: json.dumps(data, indent=2, ensure_ascii=False) + "\n" for path, data in out.items()}
    files["README.md"] = readme(registry)
    return files


def lint(registry):
    errors = []
    names = [p["name"] for p in registry["plugins"]]
    dirs = sorted(p.parent.parent.name for p in ROOT.glob("*/.claude-plugin/plugin.json"))
    if sorted(names) != dirs:
        errors.append(f"registry plugins {sorted(names)} != plugin dirs {dirs}")
    for entry in registry["plugins"]:
        for field in ("name", "displayName", "description", "version", "category"):
            if not isinstance(entry.get(field), str) or not entry[field].strip():
                errors.append(f"{entry.get('name')}: registry field '{field}' missing")
        if not re.fullmatch(r"\d+\.\d+\.\d+", entry.get("version", "")):
            errors.append(f"{entry['name']}: version must be X.Y.Z")
        plugin_dir = ROOT / entry["name"]
        if not (plugin_dir / "assets" / "logo.svg").is_file():
            errors.append(f"{entry['name']}: missing assets/logo.svg")
        if not components(plugin_dir):
            errors.append(f"{entry['name']}: no skills, commands, agents, hooks, or MCP servers")
        errors += lint_plugin(plugin_dir)
    return errors


def lint_plugin(plugin_dir):
    errors = []
    skills = plugin_dir / "skills"
    if skills.is_dir():
        for loose in skills.glob("*.md"):
            errors.append(f"{loose.relative_to(ROOT)}: loose file in skills/, move it under a skill directory")
        for skill_dir in sorted(p for p in skills.iterdir() if p.is_dir()):
            skill_md = skill_dir / "SKILL.md"
            if not skill_md.is_file():
                errors.append(f"{skill_dir.relative_to(ROOT)}: missing SKILL.md")
                continue
            meta = frontmatter(skill_md)
            if meta.get("name") != skill_dir.name:
                errors.append(f"{skill_md.relative_to(ROOT)}: frontmatter name {meta.get('name')!r} != dir {skill_dir.name!r}")
            if not meta.get("description"):
                errors.append(f"{skill_md.relative_to(ROOT)}: missing description")
    for doc in plugin_dir.rglob("*.md"):
        text = doc.read_text()
        for ref in LINK.findall(text):
            if re.match(r"[a-z]+:", ref) or ref.startswith(("/", "<", "$", "~")):
                continue
            target = (doc.parent / ref).resolve()
            if not target.is_relative_to(plugin_dir.resolve()):
                errors.append(f"{doc.relative_to(ROOT)}: link {ref} leaves the plugin, which installs alone")
            elif not target.exists():
                errors.append(f"{doc.relative_to(ROOT)}: broken link {ref}")
        if "—" in text:
            errors.append(f"{doc.relative_to(ROOT)}: contains an em dash")
    for kind in ("commands", "agents"):
        for doc in sorted((plugin_dir / kind).glob("*.md")):
            if not frontmatter(doc).get("description"):
                errors.append(f"{doc.relative_to(ROOT)}: missing description")
    return errors


def frontmatter(path):
    match = FRONTMATTER.match(path.read_text())
    if not match:
        return {}
    meta = {}
    for line in match.group(1).splitlines():
        key, sep, value = line.partition(":")
        if sep and not line.startswith((" ", "\t")):
            meta[key.strip()] = value.strip().strip("\"'")
    return meta


def main(mode):
    registry = json.loads(REGISTRY.read_text())
    files = generated(registry)
    if mode == "sync":
        for path, text in files.items():
            target = ROOT / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(text)
        print(f"wrote {len(files)} manifests")
        return 0
    errors = [f"{p}: out of date, run 'python3 scripts/plugins.py sync'" for p, t in files.items()
              if not (ROOT / p).is_file() or (ROOT / p).read_text() != t]
    errors += lint(registry)
    for err in errors:
        print(f"FAIL {err}")
    print(f"checked {len(registry['plugins'])} plugins, {len(errors)} problems")
    return 1 if errors else 0


if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in ("sync", "check"):
        sys.exit(__doc__)
    sys.exit(main(sys.argv[1]))
