#!/usr/bin/env python3
# Vendored from the `okf` plugin's skills/okf/scripts/render_okf_viewer.py so
# this kb stays self-contained (works even if that plugin is uninstalled).
"""Render OKF v0.1 derived artifacts for any bundle. Stdlib only.

Walks a bundle directory once and emits:
  - `<dir>/index.md` at every level    — OKF progressive-disclosure listings
                                          (root carries `okf_version: "0.1"`;
                                          others carry none)
  - `<bundle>/viz.html` (or --out)     — self-contained graph viewer
                                          (cytoscape + marked via CDN)

Frontmatter is read with a flat line-scan (`key: value`), the same convention
used by validate_okf.py — no nested YAML, no PyYAML dependency. Concepts link
to each other three ways, all three are read as graph edges:
  - `related: ["[[slug]]", "other-slug"]` frontmatter
  - `[[slug]]` wikilinks in the body
  - `[text](path/to/concept.md)` markdown links in the body (bundle-relative,
    absolute `/path.md` or relative to the linking file)

Usage:
  render_okf_viewer.py <bundle_dir> [--title NAME] [--out FILE]

Idempotent: re-running overwrites the same outputs.
"""
import argparse
import json
import os
import re
import sys

# Deterministic, cycling palette — assigned to types in first-seen order so
# any bundle's custom `type` values get stable, distinct colors without
# hardcoding a fixed vocabulary.
PALETTE = [
    "#8b5cf6", "#ec4899", "#3b82f6", "#10b981", "#f59e0b",
    "#ef4444", "#14b8a6", "#a855f7", "#84cc16", "#0ea5e9",
]
RESERVED = {"index.md", "log.md"}


def split_fm(text):
    m = re.match(r"\A---\r?\n(.*?)\r?\n---\r?\n?(.*)\Z", text, re.DOTALL)
    if not m:
        return {}, text
    fm = {}
    for line in m.group(1).splitlines():
        mm = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if mm:
            fm[mm.group(1)] = mm.group(2).strip()
    return fm, m.group(2)


def clean(v):
    return (v or "").strip().strip('"').strip("'").strip()


def parse_list(v):
    v = clean(v)
    if v.startswith("[") and v.endswith("]"):
        v = v[1:-1]
    if not v:
        return []
    return [x.strip().strip('"').strip("'") for x in re.split(r"[,\n]", v) if x.strip()]


def strip_wikilink(ref):
    return ref.replace("[[", "").replace("]]", "").split("|")[0].split("#")[0].strip()


def collect(root):
    concepts = []
    for dp, dn, fn in os.walk(root):
        dn.sort()
        for name in sorted(fn):
            if not name.endswith(".md") or name in RESERVED or name.startswith("_"):
                continue
            path = os.path.join(dp, name)
            fm, body = split_fm(open(path, encoding="utf-8").read())
            rel = os.path.relpath(path, root)
            slug = name[:-3]
            md_links = [
                href.split("#")[0] for href in re.findall(r"\]\(([^)\s]+)\)", body)
                if href.lower().endswith(".md") and "://" not in href
            ]
            concepts.append({
                "path": rel,
                "dirpath": dp,
                "slug": slug,
                "title": clean(fm.get("title")) or slug,
                "description": clean(fm.get("description")),
                "type": clean(fm.get("type")) or "note",
                "tags": parse_list(fm.get("tags", "")),
                "related": [strip_wikilink(r) for r in parse_list(fm.get("related", ""))],
                "wikilinks": [strip_wikilink(w) for w in re.findall(r"\[\[([^\]]+)\]\]", body)],
                "md_links": md_links,
                "sources": parse_list(fm.get("sources", "")),
                "body": body.strip(),
            })
    return concepts


def resolve_md_link(root, from_rel, href):
    """Resolve a markdown link's href to a bundle-relative path (posix, no leading /)."""
    if href.startswith("/"):
        target = href.lstrip("/")
    else:
        target = os.path.normpath(os.path.join(os.path.dirname(from_rel), href))
    return target.replace(os.sep, "/")


def write_indexes(root, concepts, bundle_label):
    by_dir = {}
    for c in concepts:
        by_dir.setdefault(c["dirpath"], []).append(c)
    dirs_to_index = set(by_dir.keys()) | {root}
    for dp, dn, _fn in os.walk(root):
        if dn:
            dirs_to_index.add(dp)
    written = []
    for dirpath in sorted(dirs_to_index):
        rel = os.path.relpath(dirpath, root)
        is_root = rel == "."
        subdirs = sorted(d for d in os.listdir(dirpath)
                          if os.path.isdir(os.path.join(dirpath, d)))
        here = sorted(by_dir.get(dirpath, []), key=lambda c: c["title"].lower())
        if not subdirs and not here:
            continue
        if is_root:
            out = ["---", 'okf_version: "0.1"', "---", "", f"# {bundle_label}", "",
                   "Graph viewer: `viz.html`.", ""]
        else:
            out = [f"# `{rel}/`", ""]
        if subdirs:
            out += ["## Groups", ""] + [f"- [`{d}/`]({d}/)" for d in subdirs] + [""]
        if here:
            out += ["## Concepts", ""]
            for c in here:
                tail = f" — {c['description']}" if c["description"] else ""
                out.append(f"- [{c['title']}]({os.path.basename(c['path'])}){tail}")
            out += [""]
        p = os.path.join(dirpath, "index.md")
        open(p, "w", encoding="utf-8").write("\n".join(out))
        written.append(p)
    return written


def build_bundle(root, concepts):
    slugs = {c["slug"] for c in concepts}
    path_to_slug = {c["path"].replace(os.sep, "/"): c["slug"] for c in concepts}
    edge_set = set()
    for c in concepts:
        targets = set(c["related"]) | set(c["wikilinks"])
        for t in targets:
            if t in slugs and t != c["slug"]:
                edge_set.add((c["slug"], t))
        for href in c["md_links"]:
            resolved = resolve_md_link(root, c["path"], href)
            target_slug = path_to_slug.get(resolved) or (
                os.path.basename(resolved)[:-3] if resolved.endswith(".md") else None
            )
            if target_slug and target_slug in slugs and target_slug != c["slug"]:
                edge_set.add((c["slug"], target_slug))
    degree = {s: 0 for s in slugs}
    for a, b in edge_set:
        degree[a] += 1
        degree[b] += 1
    types, nodes, bodies = [], [], {}
    for c in concepts:
        if c["type"] not in types:
            types.append(c["type"])
        color = PALETTE[types.index(c["type"]) % len(PALETTE)]
        nodes.append({"data": {
            "id": c["slug"], "label": c["title"], "type": c["type"],
            "description": c["description"], "tags": c["tags"],
            "resource": c["sources"][0] if c["sources"] else "",
            "color": color, "size": 24 + min(degree[c["slug"]], 6) * 4,
        }})
        bodies[c["slug"]] = c["body"]
    edges = [{"data": {"id": f"{a}__{b}", "source": a, "target": b}}
              for a, b in sorted(edge_set)]
    palette = {t: PALETTE[i % len(PALETTE)] for i, t in enumerate(types)}
    return {"nodes": nodes, "edges": edges, "bodies": bodies, "types": types, "palette": palette}


VIZ = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>__NAME__ — OKF Bundle Viewer</title>
<script src="https://cdn.jsdelivr.net/npm/cytoscape@3.28.1/dist/cytoscape.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/marked@12.0.0/marked.min.js"></script>
<style>
*{box-sizing:border-box}
body{margin:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif;font-size:14px;color:#0f172a;background:#f8fafc;display:flex;flex-direction:column;height:100vh}
header{display:flex;align-items:center;justify-content:space-between;padding:10px 16px;background:#fff;border-bottom:1px solid #e2e8f0;flex-shrink:0}
.title strong{font-size:16px;margin-right:8px}
.muted{color:#64748b;font-size:12px}
.legend{display:flex;gap:12px;font-size:12px;flex-wrap:wrap}
.legend i{display:inline-block;width:10px;height:10px;border-radius:50%;margin-right:4px;vertical-align:middle}
main{display:flex;flex:1;min-height:0}
#graph{flex:1 1 60%;background:#fff;border-right:1px solid #e2e8f0;min-width:0;position:relative}
#detail{flex:0 0 40%;overflow-y:auto;padding:18px 22px;background:#fff}
#detail h1{font-size:18px;margin:0 0 6px}
.badge{display:inline-block;font-size:11px;padding:2px 8px;border-radius:999px;color:#fff}
#detail .desc{color:#475569;margin:8px 0 12px}
#detail .tags{margin-bottom:12px}
#detail .tags span{font-size:11px;background:#f1f5f9;border:1px solid #e2e8f0;border-radius:4px;padding:2px 6px;margin:0 4px 4px 0;display:inline-block}
#detail .body{line-height:1.55}
#detail .body pre{background:#0f172a;color:#e2e8f0;padding:10px;border-radius:6px;overflow:auto}
#detail .body code{background:#f1f5f9;padding:1px 4px;border-radius:3px;font-size:13px}
#detail .body pre code{background:none;padding:0}
#detail .body table{border-collapse:collapse;margin:8px 0}
#detail .body th,#detail .body td{border:1px solid #e2e8f0;padding:4px 8px}
#detail .body a{color:#2563eb}
#detail h2{font-size:13px;margin-top:18px;color:#64748b;text-transform:uppercase;letter-spacing:.04em}
#backlinks ul{padding-left:18px;margin:4px 0}
#backlinks a{color:#2563eb;cursor:pointer}
.hint{position:absolute;bottom:10px;left:12px;color:#94a3b8;font-size:12px}
</style>
</head>
<body>
<header>
  <div class="title"><strong>__NAME__</strong><span class="muted">OKF v0.1 bundle viewer</span></div>
  <div class="legend" id="legend"></div>
</header>
<main>
  <div id="graph"><div class="hint">scroll = zoom · drag = pan · click a node</div></div>
  <section id="detail"><p class="muted">Select a node to read it.</p></section>
</main>
<script>
window.BUNDLE=__BUNDLE__;
(function(){
  const b=window.BUNDLE, byId={}; b.nodes.forEach(n=>byId[n.data.id]=n.data);
  const back={}; b.edges.forEach(e=>{(back[e.data.target]=back[e.data.target]||[]).push(e.data.source)});
  const leg=document.getElementById("legend");
  b.types.forEach(t=>{const s=document.createElement("span");s.innerHTML='<i style="background:'+b.palette[t]+'"></i>'+t;leg.appendChild(s)});
  const cy=cytoscape({container:document.getElementById("graph"),elements:[...b.nodes,...b.edges],style:[
    {selector:"node",style:{"label":"data(label)","background-color":"data(color)","width":"data(size)","height":"data(size)","color":"#334155","font-size":10,"text-valign":"bottom","text-margin-y":4,"text-wrap":"wrap","text-max-width":80}},
    {selector:"node:selected",style:{"border-width":3,"border-color":"#0f172a"}},
    {selector:"edge",style:{"width":1,"line-color":"#cbd5e1","curve-style":"bezier","opacity":.55}}
  ],layout:{name:"cose",animate:false,idealEdgeLength:90,nodeRepulsion:9000,padding:20}});
  function select(id){
    cy.nodes().unselect(); const el=cy.getElementById(id); if(el&&el.length)el.select();
    const n=byId[id]; if(!n) return;
    const bodyMd=b.bodies[id]||"";
    const tags=(n.tags||[]).map(t=>'<span>'+t+'</span>').join("");
    const bl=(back[id]||[]).map(s=>'<li><a data-id="'+s+'">'+((byId[s]||{}).label||s)+'</a></li>').join("");
    document.getElementById("detail").innerHTML=
      '<h1>'+n.label+'</h1>'+
      '<span class="badge" style="background:'+(b.palette[n.type]||'#64748b')+'">'+n.type+'</span>'+
      (n.resource?' <a class="muted" href="'+n.resource+'" target="_blank" rel="noopener">source ↗</a>':'')+
      '<p class="desc">'+(n.description||'')+'</p>'+
      (tags?'<div class="tags">'+tags+'</div>':'')+
      '<div class="body">'+marked.parse(bodyMd)+'</div>'+
      (bl?'<div id="backlinks"><h2>Linked from</h2><ul>'+bl+'</ul></div>':'');
    document.querySelectorAll('#backlinks a').forEach(a=>a.onclick=()=>select(a.dataset.id));
  }
  cy.on("tap","node",e=>select(e.target.id()));
  if(b.nodes.length) select(b.nodes[0].data.id);
})();
</script>
</body>
</html>
"""


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("bundle_dir", help="OKF bundle root to walk")
    ap.add_argument("--title", help="viewer title (default: bundle dir name)")
    ap.add_argument("--out", help="viz.html output path (default: <bundle_dir>/viz.html)")
    args = ap.parse_args()

    root = os.path.abspath(args.bundle_dir)
    if not os.path.isdir(root):
        print(f"error: not a directory: {root}", file=sys.stderr)
        return 1

    title = args.title or os.path.basename(root.rstrip(os.sep)) or "bundle"
    out = os.path.abspath(args.out) if args.out else os.path.join(root, "viz.html")

    concepts = collect(root)
    idx = write_indexes(root, concepts, title)
    bundle = build_bundle(root, concepts)
    html = VIZ.replace("__NAME__", title).replace("__BUNDLE__", json.dumps(bundle))
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    open(out, "w", encoding="utf-8").write(html)

    print(f"generated {len(idx)} index.md + {os.path.relpath(out)} "
          f"({len(bundle['nodes'])} nodes, {len(bundle['edges'])} edges)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
