---
name: quality-gates
description: Concrete checks to run before calling work done, with rules for reporting results honestly. Use before handing off, opening a PR, or merging code written by you or a subagent.
---

# Quality gates

Run the repo's own commands. Find them in `package.json` scripts, `Makefile`, CI config, or the contributing docs. Do not invent commands.

## Gates

Run in this order and stop at the first failure.

1. **Lint and format.** The project's linter on changed files at minimum. Fix with the auto-fixer, then re-run.
2. **Typecheck.** Whole project, not just changed files. Types break across files.
3. **Tests.** Run tests for the changed area first, then the full suite once before handoff. Add or update a test for each behavior you changed.
4. **Build.** Run once, at the end, after everything else passes. Do not run builds in parallel workers because concurrent builds exhaust memory. Verify once after merging.
5. **Security scan.** Run the dependency audit if dependencies changed. Grep the diff for hardcoded secrets, new `eval`, string-built SQL, and disabled TLS or auth checks.

Add these when the change warrants them.

| Change touches | Extra gate |
|----------------|-----------|
| Public API, schema, config format | Check callers and docs, note breaking changes |
| Migrations | Apply on a scratch database and roll forward |
| Hot path or query | Measure before and after, report the numbers |
| UI | Run the app and exercise the changed flow, including empty and error states |
| Deploy config, auth, payments | Second reviewer, and a rollback plan in the PR |

## Reporting rules

- Report the exact command and its result. Never write "tests pass" from memory or from a previous run.
- Skipped, quarantined, or `xfail` tests are reported as skipped, with a count. They are not passes.
- If a gate cannot run (missing tool, no network, no credentials), say so and mark the gate as not verified. Do not mark it green.
- A flaky failure is a failure. Re-run once to classify it, report both runs, and do not hide it.
- Pre-existing failures are reported separately from ones you caused. Prove it by running the same command on the base branch.
- Do not weaken a gate to get green. No deleting tests, loosening assertions, adding `skip`, raising lint ignores, or lowering coverage thresholds without the user's approval.
- Do not report "done" with failures remaining. Report "blocked" and list what is failing.

## When a gate fails

1. Read the actual error. Fix the cause, not the symptom.
2. Re-run the failed gate, then every earlier gate, since the fix may break them.
3. If the same gate fails three times with different fixes, stop and report what you tried.
4. If the failure is outside your change, report it and ask before widening scope.

## Review checklist

- The diff contains only changes that trace to the request. No drive-by refactors or reformatting.
- New behavior has a test that fails without the change.
- Errors are handled or propagated, never swallowed.
- No debug output, commented-out code, or stray TODOs without an owner.
- Docs and examples match the new behavior.

## Anti-patterns

- Running only the tests you wrote.
- Declaring success after the build passes but before tests ran.
- Using coverage percentage as proof of correctness.
- Fixing a type error with `any` or a cast.
- Silent retries until green.
