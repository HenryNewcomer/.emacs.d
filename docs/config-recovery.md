# Checked configuration builds and recovery

This repository is transitioning from direct `org-babel-load-file` startup to a validated, last-known-good configuration build. The current live loader has not been switched yet.

## Commands

Run the builder tests:

```sh
./scripts/test-config-build
```

Validate `settings.org` without replacing any generated output:

```sh
./scripts/check-config
```

Validate and atomically promote the generated Lisp to the ignored recovery location:

```sh
./scripts/build-config
```

Run a source-load smoke test in a child Emacs with a temporary HOME:

```sh
./scripts/smoke-config
```

The smoke test reuses the installed packages read-only, redirects future package state into its temporary HOME, blocks package installation/refresh and URL retrieval, and deletes its temporary tree on exit. It does not exercise GUI frames, delayed timers, interactive buttons, external tools, or Pico hardware.

## What the checked build proves

The builder:

1. Copies the on-disk Org source into a disposable staging directory.
2. Runs Org lint and rejects unsafe active-block structure.
3. Preflights the tangle plan and rejects alternate output destinations or tangle-time evaluation.
4. Tangles into exactly one staging file.
5. Runs `check-parens` and reads every top-level Lisp form.
6. Asserts that important definitions survived tangling.
7. Byte-compiles in a disposable batch Emacs while forbidding package refresh or installation.
8. Renames the validated source over the last-known-good output only after every prior phase succeeds.

Compilation warnings are collected but are not fatal by default while the inherited monolith is being repaired. Set `HENRY_CONFIG_STRICT_WARNINGS=1` to reject them after all diagnostics have been collected.

## If a configuration edit fails

1. Do not reload the full init in the primary working Emacs.
2. Run `./scripts/check-config` and address the first source diagnostic.
3. If the failure is unclear, run `./scripts/test-config-build` to distinguish a builder regression from a source problem.
4. Keep `/Users/henry/.emacs` and the current running Emacs untouched.
5. Use `./scripts/smoke-config` to test the candidate in a disposable child process.
6. Only after check, build, and smoke pass should a separate GUI candidate be started for lived-use verification.

The recovery artifact is:

```text
/Users/henry/.emacs.d/var/last-known-good/settings.el
```

It is intentionally ignored because it is generated machine state. Until the canonical loader gate lands, normal startup still uses `org-babel-load-file`; building the recovery artifact does not change the active loader.

## Current limitations

- The checker validates the file on disk, not unsaved text in a live Org buffer.
- Static compilation does not execute ordinary top-level forms.
- The child smoke process cannot prove GUI layout or interactive behavior.
- The current package installation and custom theme are still machine-local dependencies.
- The current loader does not yet prefer the last-known-good artifact.

These limitations are explicit so a green static check is never mistaken for complete startup proof.
