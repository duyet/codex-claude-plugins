#!/usr/bin/env python3
"""Validate an OKF v0.1 bundle. Stdlib only — no PyYAML required.

Usage: python3 validate_okf.py <bundle_dir>

Exit code 0 if conformant (broken cross-links are warnings, not failures),
1 if any conformance error is found.
"""
import os
import re
import sys

RESERVED = {"index.md", "log.md"}


def split_frontmatter(text):
    """Return (frontmatter_str_or_None, has_delimited_block)."""
    if not text.startswith("---"):
        return None, False
    m = re.match(r"^---\s*\n(.*?)\n---\s*(?:\n|$)", text, re.DOTALL)
    if not m:
        return None, False
    return m.group(1), True


def frontmatter_keys(fm):
    """Crude top-level key scan — enough for conformance checks."""
    keys = {}
    for line in fm.splitlines():
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if m:
            keys[m.group(1)] = m.group(2).strip()
    return keys


def main():
    if len(sys.argv) != 2:
        print("usage: validate_okf.py <bundle_dir>", file=sys.stderr)
        return 2
    root = os.path.abspath(sys.argv[1])
    if not os.path.isdir(root):
        print(f"error: not a directory: {root}", file=sys.stderr)
        return 2

    errors, warnings = [], []
    concept_count = 0

    for dirpath, _dirs, files in os.walk(root):
        for name in files:
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, root)
            with open(path, encoding="utf-8") as f:
                text = f.read()
            fm, delimited = split_frontmatter(text)
            is_root_index = (rel == "index.md")

            if name in RESERVED:
                # Reserved files carry no frontmatter, except root index.md may
                # carry only okf_version.
                if delimited:
                    keys = frontmatter_keys(fm)
                    if is_root_index and set(keys) <= {"okf_version"}:
                        pass
                    else:
                        errors.append(
                            f"{rel}: reserved file must not carry frontmatter"
                            + (" (root index.md may carry only okf_version)"
                               if is_root_index else "")
                        )
                continue

            # Non-reserved concept file.
            concept_count += 1
            if not delimited:
                errors.append(f"{rel}: missing parseable YAML frontmatter block")
                continue
            keys = frontmatter_keys(fm)
            if not keys.get("type"):
                errors.append(f"{rel}: frontmatter missing non-empty 'type'")

            # Warn on broken absolute (bundle-relative) cross-links.
            for target in re.findall(r"\]\((/[^)\s]+\.md)\)", text):
                dest = os.path.join(root, target.lstrip("/"))
                if not os.path.isfile(dest):
                    warnings.append(f"{rel}: broken link -> {target}")

    for w in warnings:
        print(f"warning: {w}")
    for e in errors:
        print(f"error: {e}")

    print(f"\nchecked {concept_count} concept doc(s): "
          f"{len(errors)} error(s), {len(warnings)} warning(s)")
    if errors:
        print("NOT conformant with OKF v0.1")
        return 1
    print("conformant with OKF v0.1")
    return 0


if __name__ == "__main__":
    sys.exit(main())
