# Emacs Configuration — TODOs & Mission Control

**Created:** July 15, 2026
**Purpose:** A compact source of truth for the current Emacs configuration, its safety contract, active work, durable intentions, and longer-term direction.

**Last updated:** July 15, 2026 — The checked-build harness, recovery guide, and disposable child-process smoke path are implemented on branch `2026-07-15/emacs-foundation-arboris`. Its nine builder tests pass, and the real configuration is rejected at the three previously identified Org lint locations. No review-driven change has yet been made to `settings.org`.

## How to use this file

For a cold start, read these sections in order:

1. [Current situation](#current-situation)
2. [Current gate](#current-gate)
3. [Safety contract](#safety-contract)
4. [Work on next](#work-on-next)
5. The relevant item under [Known issues](#known-issues)

Keep this document useful as orientation, not as an exhaustive diary:

- Replace the **Current situation** block when truth changes; preserve displaced history in an archive only when it remains useful.
- Keep **Work on next** bounded to one convergence point and its next few actions.
- Put settled choices in the **Decisions log** and unresolved choices in the **Decisions queue**.
- A checked item means implemented **and verified**, not merely written.
- Preserve exact commands, paths, errors, and proof when they carry diagnostic value.
- If this live file grows beyond roughly 700–900 lines, archive completed history and move deeper designs into `docs/`.

### Status and priority language

- **Planned:** accepted work that has not begun.
- **Active:** work has begun and names its next proof.
- **Partial:** useful behavior exists, but the acceptance gate remains open.
- **Awaiting manual verification:** automated proof passed; lived use has not.
- **Blocked:** an external dependency prevents meaningful progress.
- **Decision needed:** implementation awaits an explicit choice.
- **Verified:** implementation and acceptance evidence both exist.
- **Deferred:** intentionally postponed with a reason.
- **Superseded:** replaced by a newer direction without erasing the earlier context.

Priority indicates impact, independently of status:

- **P0:** can prevent startup, lose work, or terminate unrelated processes.
- **P1:** definite broken behavior or reproducibility failure.
- **P2:** workflow, discoverability, or visual friction.
- **P3:** optional polish or exploration.

## Current situation

**Date:** July 15, 2026
**Machine:** Henry's Mac, GNU Emacs 30.2
**Active branch:** `2026-07-15/emacs-foundation-arboris`
**Last-known-good base:** `5665c0f` (`2026-07-15 Improve editor workflows and Pico tooling`), pushed to `origin/main`
**Human-authored configuration:** `settings.org`
**Actual live loader:** `/Users/henry/.emacs`
**Tracked but inactive loader:** `/Users/henry/.emacs.d/.emacs`

### Verified truth

- The working branch began from a clean `main` synchronized with `origin/main`.
- The live Emacs reports `/Users/henry/.emacs` as `user-init-file`.
- The `main` baseline tracks only `.emacs`, `.gitignore`, and `settings.org`; the catch-all ignore rule hides required runtime dependencies such as the custom theme.
- `org-lint` reports three structural problems in `settings.org`, including an incomplete source block beginning at line 999.
- A temporary tangle passes Lisp reader and parenthesis checks, but malformed Org can silently omit code before those checks see it.
- The generated configuration has no lexical binding. A stored Pico button callback demonstrably fails because it cannot capture its command argument.
- Actual `emacs-init-time` for the inspected session was about 4.1 seconds; idle-timer package loads continue after that measurement.
- `rainbow-delimiters-mode` on the entire Org buffer treats separate prose and source blocks as one delimiter stream. Letting Org natively fontify embedded programming blocks instead produced 3,112 correctly colored delimiters and zero false unmatched/mismatched faces in `settings.org`.
- `/Users/henry/dev/arboris` is the authoritative Heartroot Mist palette and VS Code theme source. `/Users/henry/dev/verditer-theme` and `/Users/henry/dev/laguna-theme` are the existing standalone Emacs theme repositories.

### Immediate next action

Use the checked builder to repair only the three known Org structural defects, then prove static build, atomic promotion, and disposable source-load smoke before changing normal startup behavior.

## Current gate

| Gate | Intended outcome | Status | Risk | Last evidence | Next proof |
|---|---|---|---|---|---|
| G0 | Preserve, review, and record intent | **Verified** | Low | Base commit pushed; review/inventory complete; mission-control artifact prepared | Begin the checked-build gate |
| G1 | Checked configuration build and recovery path | **Active** | P0 | Nine ERT tests pass; malformed input and escaped tangle output preserve a sentinel last-known-good file | Repair the three real Org defects, then pass check/build/smoke |
| G2 | Canonical tracked boot | Planned | P0 | Live loader confirmed outside the repository | A separate Emacs process starts from tracked `early-init.el`/`init.el` without touching the live loader |
| G3 | Correctness and safety repairs | Planned | P0/P1 | Definite failures catalogued | Focused tests pass for each repaired behavior |
| G4 | Coherent interaction architecture | Planned | P2 | Existing leader map audited | New map is discoverable and preserves approved workflows |
| G5 | Modern completion/navigation/language flow | Planned | P1/P2 | Package and executable inventory complete | One language at a time passes navigation, completion, diagnostics, and formatting smoke checks |
| G6 | Safe Pico console | Planned | P0/P2 | Broad `kill -9`, synchronous commands, and undefined actions confirmed | Owned-process lifecycle and mocked command tests pass |
| G7 | Arboris Heartroot Mist theme laboratory | Planned | P2/P3 | Canonical palette and Emacs predecessors located | Reload failure rolls back; specimen frame and face tests pass |
| G8 | Visual, window, and startup polish | Planned | P2/P3 | Conflicting frame/display rules documented | Cross-machine lived-use checklist passes |

## Safety contract

These are invariants for all work on this repository.

1. `settings.org` remains the human-authored source of truth. Do not hand-edit generated `settings.el`.
2. Never replace a last-known-good generated configuration unless Org lint, tangle, reader, compile, and smoke checks pass.
3. Test risky loader/startup changes in a separate Emacs process and isolated init directory before changing `/Users/henry/.emacs`.
4. Keep the existing home loader as a rollback path until the canonical tracked boot has passed a real restart on each machine.
5. Do not combine a loader cutover and broad behavior refactor in the same commit.
6. Keep commits bounded and independently understandable. One repair or coherent gate slice per commit is preferred.
7. Never run full-init reload repeatedly inside the primary working session. Reload a bounded module or restart into an isolated test instance.
8. Preserve the current generated output and base commit before structural Org edits.
9. A package update is an explicit maintenance operation followed by smoke tests, never an incidental startup side effect.
10. Hardware commands may terminate only a selected process owned by Emacs. No wildcard device-wide `kill -9` in routine actions.
11. A theme may alter faces only through reversible theme declarations. It must not install global font-lock rules or permanently mutate unrelated faces when loaded.
12. If an automated check and lived behavior disagree, the gate remains open and the disagreement is recorded.

### Recovery must become boring

Gate G1 is complete only when a short recovery guide exists and has been exercised:

- Start Emacs without user configuration.
- Locate the last-known-good generated configuration and diagnostic log.
- Run the checked build manually.
- Restore or select the last-known-good artifact without editing the broken source under pressure.
- Start an isolated GUI instance with the candidate configuration.
- Leave the primary working Emacs untouched until the candidate is proven.

## Carry-forward intentions

These are Henry's explicit workflow and visual preferences. Do not quietly “simplify” them away.

### Line numbers

- Relative line numbers remain available in every ordinary editing context, including prose, Org, and Markdown, because they support multi-line movement, copying, and orientation.
- Modes where buffer line numbers are technically misleading or unsupported—such as minibuffers, image/PDF viewers, and terminal emulators—may opt out deliberately.
- The current line should remain clearly distinguishable and show an absolute anchor if that proves most useful.

### Whitespace

- Deleting trailing whitespace before every save is intentional, including in Markdown.
- Prefer explicit Markdown/HTML constructs when a hard line break is wanted rather than preserving invisible trailing spaces.
- Whitespace display may still be visually tuned independently from whitespace cleanup.

### Delimiter depth

- Rainbow delimiters are wanted throughout programming languages and Markdown, and inside embedded programming blocks in Org.
- Do not solve mixed-mode failures by disabling the feature broadly.
- Org source blocks must be fontified independently so prose or one malformed block cannot contaminate every later block.
- Markdown acceptance requires an experiment: ordinary Markdown parentheses should remain useful while fenced blocks reset parsing independently and one unmatched delimiter must not recolor the rest of the document.

### Frame behavior

- Maximized is the general baseline.
- The Mac mini's very wide monitor needs an easy left-half/right-half layout.
- The MacBook Pro should support a near-full work-area layout that reaches toward the Dock without entering macOS true fullscreen.
- Frame layout must be easy to cycle manually and may have a per-machine default in ignored local configuration.

### Personal character

- Preserve the literate configuration, Evil editing grammar, Org workflows, Magit, Vterm, Pico tooling, Ellama, and the distinctive Arboris/Verditer visual lineage.
- Prefer one coherent interaction model over overlapping mechanisms, but do not erase useful personal commands merely because a built-in alternative exists.

## Work on next

### Current convergence point: make change safe before making it broad

1. [x] Commit the TODO/mission-control foundation on the dated branch.
2. [x] Add an ignored runtime/build layout and explicit tracked exceptions without changing startup behavior.
3. [x] Implement a checked configuration builder that writes only to a temporary destination until every validation step passes.
4. [x] Add an isolated batch source-load smoke path; retain the separate-GUI candidate as a later manual gate.
5. [x] Document recovery and prove that malformed Org/Lisp/compiler input cannot replace a sentinel last-known-good file.
6. [ ] Repair the three known Org structural errors as the first test-driven `settings.org` change.
7. [ ] Add tracked `early-init.el` and `init.el`, but keep `/Users/henry/.emacs` unchanged until the isolated boot passes.

### Non-goals for the first PR slice

- No wholesale leader-map remap.
- No package upgrades or completion-stack migration.
- No replacement of Verditer in the live configuration.
- No broad Pico rewrite before owned-process tests exist.
- No deletion of the existing loader or last-known-good generated configuration.
- No attempt to modernize every custom command at once.

The first PR may include the checked build, canonical tracked boot files, structural Org repairs, and narrowly related reproducibility fixes if each slice remains independently proven. Theme development belongs on its own Arboris branch and can proceed in parallel once the laboratory exists.

## Known issues

### P0 — Repository clone does not reproduce live startup

**Symptom:** The tracked `.emacs.d/.emacs` is not the file Emacs loads, and required theme files are ignored.
**Impact:** A fresh clone can start without this configuration or abort during theme loading.
**Root cause:** Confirmed: standard init-path mismatch plus a catch-all `.gitignore`.
**Fix direction:** Track canonical `early-init.el`/`init.el`, required modules, tests, and an explicit theme dependency; move Customize output to ignored runtime state.
**Fixed when:** A clean isolated init directory and a second machine can boot from only tracked/pinned inputs.

### P0 — Malformed Org can silently remove configuration

**Symptom:** The block beginning near `settings.org:999` is not tangled; another active end marker is orphaned.
**Impact:** Commands appear to exist in the literate source but are absent at runtime.
**Root cause:** Confirmed malformed source markers.
**Fix direction:** Checked build plus focused structural repairs.
**Fixed when:** Org lint is clean, expected definitions are asserted after tangle, and a malformed fixture fails closed.

### P0 — Pico actions can affect unrelated processes

**Symptom:** Routine commands shell through wildcard `lsof` output to `kill -9`.
**Impact:** Other serial/device sessions can be terminated.
**Root cause:** Confirmed lack of selected-device and owned-process state.
**Fix direction:** Asynchronous process objects, explicit device selection, graceful interruption, targeted escalation, and confirmations.
**Fixed when:** Tests prove only the owned mock process is signaled and unavailable/destructive actions are represented honestly.

### P1 — Generated custom callbacks need lexical scope

**Symptom:** Pico panel button invocation can fail with `void-variable command`.
**Impact:** Interactive controls fail after rendering normally.
**Root cause:** Confirmed dynamic binding in generated configuration.
**Fix direction:** Move custom behavior into prefixed, lexically bound modules and compile them.
**Fixed when:** Callback tests pass after the defining scope has returned and compiler free-variable warnings are accounted for.

### P1 — Package activation and update behavior is unreliable

**Symptom:** Some deferred packages never enable; the custom updater upgrades nothing; several configured executables are absent or mismatched.
**Impact:** Features look configured but do not work, while post-startup timers add latency.
**Root cause:** Confirmed ineffective `:defer` triggers, obsolete symbols/options, and executable assumptions.
**Fix direction:** Semantic `use-package` triggers, an explicit maintenance command, executable capability checks, and one language migration at a time.
**Fixed when:** Declared features have activation tests and package maintenance produces an auditable before/after report.

### P2 — Rainbow delimiters misread mixed Org structure

**Symptom:** Parenthesis colors become incorrect partway through `settings.org`, including false unmatched faces in comments and later blocks.
**Impact:** A useful structural signal becomes misleading.
**Root cause:** Confirmed whole-document Org parsing across independent embedded languages.
**Fix direction:** Keep the `prog-mode` hook; remove the whole-Org parser; use native source-block fontification. Prototype a boundary-aware Markdown approach.
**Fixed when:** `settings.org` has zero false error faces and fixtures prove one source block cannot contaminate the next.

### P2 — Frame rules conflict

**Symptom:** Maximized settings are duplicated while a late startup hook attempts half-screen sizing after the initial frame exists.
**Impact:** Startup layout is inconsistent across the Mac mini and MacBook Pro.
**Root cause:** Confirmed competing declarative and late imperative policies.
**Fix direction:** One frame-layout module using monitor work area, per-machine preference, and explicit cycle/left/right/maximize/near-full commands.
**Fixed when:** Both machines pass their layout checklist and new frames inherit the intended behavior.

## Roadmap

### G0 — Preserve, orient, and baseline

**Intent:** Make the project understandable before altering behavior.
**Why now:** Review findings need durable alignment and explicit user preferences.
**Done when:** This TODO is committed; current branch/base/loader are recorded; no hidden live-buffer change remains.

### G1 — Checked configuration build and recovery

**Intent:** Make configuration failure local, visible, and reversible.
**Why now:** Every later refactor depends on safe proof.
**Scope:** Org lint, temporary tangle, Lisp reader/check-parens, byte compilation, expected-definition assertions, isolated startup, diagnostics, last-known-good promotion.
**Non-goals:** Package migration and visible redesign.
**Done when:** A deliberately broken fixture fails without replacing the good artifact, while the good candidate starts separately.

### G2 — Canonical boot and dependency truth

**Intent:** Make a clone capable of reproducing startup.
**Scope:** `early-init.el`, `init.el`, explicit `.gitignore`, Customize file, runtime directories, package/bootstrap separation, theme dependency declaration.
**Done when:** A clean isolated checkout starts without depending on an untracked home loader or theme copy.

### G3 — Correctness and reproducibility repairs

**Intent:** Remove definite broken/no-op behavior before redesign.
**Scope:** Org structure, lexical closures, package updater, Magit command, Markdown/Python executables, Undo Tree options, hooks, reload idempotence, backup/session directory creation.
**Done when:** Each repaired behavior has a focused automated or manual proof and startup remains clean.

### G4 — Interaction architecture

**Intent:** Give every command a stable, discoverable place without flattening Henry's workflow.
**Direction:** One leader map across Evil normal/motion/visual states; built-in which-key; stable namespaces for buffers, files, projects, windows, search, code, Git, Org, evaluation, toggles, help, session, and devices.
**Done when:** A printed keymap inventory has no accidental unreachable bindings, delayed bindings, or unexplained prefix meanings.

### G5 — Completion, navigation, and language tooling

**Intent:** Use one composable path for project context, definitions, references, diagnostics, and completion.
**Direction:** Project.el + Xref + Eglot where supported; a deliberate completion UI; tree-sitter only after grammar readiness; retain a tested fallback where LSP is unavailable.
**Done when:** C/C++ and Python each pass independent open/navigate/complete/diagnose/format workflows before legacy tooling is removed.

### G6 — Safe asynchronous Pico console

**Intent:** Keep the delightful device workflow while making process ownership and state explicit.
**Direction:** Transient entry point, asynchronous argv-based commands, selected device, process sentinel, reusable telemetry side window, honest disabled actions, confirmations.
**Done when:** Mocked lifecycle tests and a live device checklist pass without wildcard process termination.

### G7 — Arboris Heartroot Mist theme laboratory

**Intent:** Create a new Emacs theme descended from Verditer and faithful to the Arboris Heartroot Mist semantic palette.
**Non-goal:** Do not overwrite or rename Verditer; it remains a fallback and historical reference.
**Done when:** The new package has explicit provenance/license, reversible faces, specimens, reload rollback, batch tests, contrast checks, screenshots, and lived approval before `.emacs.d` switches to it.

### G8 — Visual, window, and performance polish

**Intent:** Make Emacs calmer, more legible, and more spatially predictable while retaining the approved information density.
**Scope:** Theme face coverage, global line-number quality, whitespace appearance, mixed-mode delimiters, frame profiles, side-window rules, layout undo/repeat maps, startup measurement.
**Done when:** Mac mini and MacBook Pro lived-use checklists pass and startup has no unexplained idle-load burst.

## Theme laboratory track

### Source and repository model

The durable sources currently are:

- `/Users/henry/dev/arboris/src/palettes/heartroot-mist.js` — canonical palette and mood.
- `/Users/henry/dev/arboris/src/tokens/` — shared semantic and syntax roles.
- `/Users/henry/dev/arboris/themes/generated/heartroot-mist-color-theme.json` — generated VS Code behavior reference.
- `/Users/henry/dev/verditer-theme/verditer-theme.el` — Emacs face-coverage and personal-workflow reference.
- `/Users/henry/dev/verditer-theme/extras/sample.org` — seed specimen.

**Recommendation:** extend `/Users/henry/dev/arboris` into a multi-editor theme repository. Add an Emacs target that generates `arboris-heartroot-mist-theme.el`, providing the theme symbol `arboris-heartroot-mist`, from the same Heartroot Mist palette and semantic roles that generate the VS Code theme. Consume a pinned Arboris revision from `.emacs.d`; never maintain a second hand-edited copy under `.emacs.d/themes`.

Before publishing, decide and record licensing. Verditer is GPLv3-derived but lacks a tracked license file; Arboris is currently marked `UNLICENSED`. A derived theme needs explicit provenance and a real compatible license file.

### Proposed package layout

```text
arboris/
└── emacs/
    ├── themes/
    │   └── arboris-heartroot-mist-theme.el
    ├── fixtures/
    │   ├── sample.org
    │   ├── sample.md
    │   ├── sample.el
    │   ├── sample.py
    │   └── sample.cpp
    ├── dev/
    │   └── preview.el
    └── test/
        ├── theme-load-test.el
        ├── face-coverage-test.el
        └── contrast-test.el
```

### Edit, reload, and preview loop

1. Edit the palette, semantic roles, or Emacs face mapping in `/Users/henry/dev/arboris`, never an installed copy.
2. Generate and validate a temporary Emacs candidate. Atomically replace the last-known-good generated theme only after validation passes.
3. Keep the primary editing session on its stable theme. Run the preview in a separate disposable Emacs process because themes are global to an Emacs process, not isolated per frame.
4. Reuse one preview process/window. It may watch the validated generated file with a debounced file notification, while retaining an explicit manual reload command.
5. If generation or loading fails, leave the last-known-good theme untouched and show the diagnostic in the preview process.
6. Refresh font-lock in every preview fixture after a successful reload.

The preview process should expose representative, read-only fixtures in named tabs rather than squeezing every case into one grid:

- Org prose, headings, TODO states, tables, links, lists, quotes, and source blocks
- `settings.org` as a real mixed-mode stress case
- Emacs Lisp
- Python
- C/C++
- JavaScript/JSON/web syntax
- Markdown prose and fenced code
- Dired and Ibuffer
- Magit/diff
- compilation, warnings, Flymake/Eglot diagnostics, completion, search, region, and matching delimiters
- Vterm/ANSI colors where available

Every visual mutation belongs in `custom-theme-set-faces` or `custom-theme-set-variables`. Do not use global `set-face-attribute`, `font-lock-add-keywords`, hooks, advice, or keybindings from the theme file.

### Theme acceptance checks

- The theme loads in `emacs -Q` with only the candidate package on `load-path`.
- Loading, disabling, reloading, and re-enabling is repeatable.
- A deliberate syntax error restores the previous theme instead of leaving the session unreadable.
- Every referenced face exists or is guarded by package availability.
- Default, comments, line numbers, region, search, errors, warnings, diffs, and modelines meet documented contrast targets.
- Generated/ported colors retain a provenance record to the Arboris palette commit.
- The preview process renders without mutating user files or starting external processes.

## Window and repetition vocabulary

- **`winner-mode`:** records Emacs window configurations so `winner-undo` and `winner-redo` can step backward/forward through split, resize, and buffer-layout changes. It is layout undo, not text undo.
- **`repeat-mode`:** lets a family of marked commands continue with short single keys after the first full binding—for example, repeated resize, text-scale, or next/previous actions. It does not make every command repeat automatically.
- **Declarative side-window rules:** `display-buffer-alist` states where special buffers should appear, how large they should be, and whether an existing window should be reused. Pico telemetry, help, compilation, and terminals should request display rather than manually splitting whichever window happens to be selected.

## Decisions queue

| ID | Decision | Options | Recommendation | Blocks | Status |
|---|---|---|---|---|---|
| D1 | Arboris Emacs repository shape | Add Emacs target to existing Arboris repo; standalone Heartroot Mist package; standalone multi-theme Emacs collection | Add an Emacs target to the existing Arboris repository so one palette/semantic source generates both editors | G7 scaffold | Recommended |
| D2 | Theme license | GPLv3-compatible derived work; another license after provenance review; private-only | Use a real GPLv3-compatible license if Verditer code is duplicated, and add missing license files | Publishing G7 | Decision needed |
| D3 | Frame default selection | Monitor geometry auto-detection; per-machine local setting; one universal default | Per-machine local default plus explicit cycle/maximize/left/right/near-full commands; geometry may provide a safe fallback | G8 | Provisional |
| D4 | Completion UI | Correct Company; built-in completion preview; Corfu | Prototype built-in completion preview first, retain Company until language workflows prove the replacement | G5 | Decision needed later |
| D5 | Undo history | Repair Undo Tree; built-in undo-redo; another persistent-history design | Decide only after documenting whether cross-session tree persistence is genuinely used | G3/G5 | Decision needed later |
| D6 | First PR boundary | Planning only; build+boot foundation; broad modernization | Build+boot foundation with only narrowly required correctness repairs | Current branch | Recommended |

## Decisions log

### 2026-07-15 — Preserve global line-number utility

Relative line numbers are intentional across ordinary programming and prose buffers. Visual cleanup must improve their legibility rather than remove them from non-programming work.

### 2026-07-15 — Preserve global trailing-whitespace cleanup

Trailing whitespace is intentionally deleted on save in every editable file type. Explicit markup should represent meaningful line breaks.

### 2026-07-15 — Repair mixed-mode delimiter coloring instead of narrowing it

Rainbow delimiters remain desired across programming languages and Markdown and within Org source blocks. Org embedded-language fontification is the confirmed direction; Markdown needs a boundary-aware proof.

### 2026-07-15 — New Arboris theme, not a destructive Verditer rewrite

Heartroot Mist will become a separately named Emacs theme with its own development and rollback path. Verditer remains available until the new theme earns replacement through lived use.

## Verification ritual

Gate G1 should collapse these into one documented command, while retaining individual diagnostics:

1. Confirm the intended branch and clean/understood worktree.
2. Run Org lint and fail on malformed active blocks.
3. Tangle into a temporary directory.
4. Run reader and `check-parens` validation.
5. Byte-compile with the intended package load path and classify every warning.
6. Assert important expected definitions and keymap entries exist.
7. Start a batch Emacs using an isolated init directory.
8. Start a separate GUI candidate and perform the focused lived-use checklist.
9. Promote the candidate to last-known-good only after all required proof passes.
10. Record commit, machine, Emacs version, commands, and results here or in a linked concise report.

### Focused lived-use checklist

- Open, edit, save, undo, redo, copy, paste, and search in `settings.org`.
- Confirm relative line-number movement in programming, Org, and Markdown buffers.
- Confirm trailing whitespace is removed on save.
- Confirm delimiter colors reset correctly across separate Org/Markdown code blocks.
- Open Magit, Dired, Vterm, Org Agenda, and the Pico entry point without startup errors.
- Create/delete/switch windows, then exercise layout undo/redo when G8 lands.
- Open a new frame and verify the machine's selected frame layout.
- Disable/re-enable the active theme and verify readable fallback behavior.

## Firm backlog

- Replace startup-time network/package installation with explicit bootstrap and maintenance commands.
- Preserve GNU and NonGNU archives; remove the retired Org archive unless a deliberate external Org policy replaces it.
- Replace ineffective numeric `:defer` timers with semantic triggers.
- Correct the Magit dispatch binding, Python executable, Markdown renderer, C++ hook typo, and invalid Undo Tree options.
- Separate machine-local paths, agenda files, hardware selection, and provider configuration into ignored local state with safe defaults.
- Make backup, undo, desktop, cache, and generated directories explicit and self-creating.
- Replace broad global buffer killing with project-aware, confirming behavior.
- Make reload bounded and idempotent; use restart for full configuration replacement.
- Introduce the approved leader taxonomy with which-key labels.
- Stage Project.el/Xref/Eglot adoption one language at a time.
- Add owned-process Pico tests before replacing the current control panel.
- Normalize repository line endings in a dedicated, reviewable commit after behavior is protected.
- Add a README with installation, bootstrap, recovery, update, and theme-development instructions.

## Tentative ideas

- Generalize the first Emacs target to additional Arboris facets only after Heartroot Mist proves the face mapping and test contract.
- Add screenshot or rendered-fixture comparison for the theme after deterministic capture is proven.
- Add an interactive configuration doctor showing loader path, generated artifact age/hash, package/executable capabilities, theme source, and last smoke result.
- Use `org-modern` only after comparing it in the theme specimen; do not assume it is automatically calmer than the existing Org presentation.
- Explore a small frame-layout Transient if cycling commands become numerous enough to justify a menu.
- Consider additional Arboris facets for Emacs only after Heartroot Mist establishes the face mapping and test contract.

## Scratchpad

Keep at most ten active entries. Resolve or absorb the oldest before adding beyond that limit.

Format:

```text
[YYYY-MM-DD] (source) Note — Resolve when: condition — by: name
```

- [2026-07-15] (Review) The active runtime Verditer copy differs from `/Users/henry/dev/verditer-theme` in two colors and is ignored. Preserve both as evidence before theme integration. — Resolve when: provenance and intended values are recorded in G7. — by: Allara
- [2026-07-15] (Inventory) `/Users/henry/dev/arboris` has no configured Git remote even though its package metadata names `HenryNewcomer/arboris-theme-collection`. — Resolve when: remote/publication intent is verified before cross-repo automation. — by: Allara
- [2026-07-15] (Rainbow experiment) Org native embedded fontification yielded 3,112 colored delimiters and zero false unmatched/mismatched faces without whole-buffer Org rainbow parsing. — Resolve when: a regression fixture and configuration change land. — by: Allara

## Change log

- **2026-07-15:** Created the compact mission-control structure; recorded baseline, safety contract, user-approved display invariants, phased roadmap, Arboris laboratory direction, verification ritual, and initial decisions.
