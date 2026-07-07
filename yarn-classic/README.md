# Yarn Classic (v1) — direct access to Chainguard Libraries

[`demo.sh`](demo.sh) shows how to point Yarn Classic at
[Chainguard Libraries for JavaScript](https://edu.chainguard.dev/chainguard/libraries/javascript/)
and install packages directly from `libraries.cgr.dev`.

## What the script does

Running `demo.sh` creates a fresh, throwaway project in a git-ignored `work/`
subdirectory, applies the registry and authentication configuration, and
installs a couple of packages so you can watch them resolve through Chainguard
Libraries.

The project is a **hollow shell** — it has no application code and does
nothing on its own. Its only job is to prove that the configuration is correct
and that dependency resolution works. That said, the configuration steps are
exactly what you would apply to a real Yarn Classic project, so treat the
script as a working template rather than a throwaway.

## Configuration

| What | Value |
|---|---|
| Config file | project `.npmrc` |
| Registry | `https://libraries.cgr.dev/javascript/` (trailing slash matters) |
| Auth mechanism | base64-encoded `identity:token` in `_auth`, plus `always-auth=true` |

Yarn Classic's own `yarn config` does not handle registry auth reliably, so the
script writes a project `.npmrc` directly instead.

## Run it

Export a pull token first (see [`../tools/README.md`](../tools/README.md)):

```bash
eval "$(chainctl auth pull-token --output env --repository=javascript)"
./demo.sh
```

## Iterate

To test a different package, edit the `yarn add` line near the end of
`demo.sh` and run it again. Each run wipes and recreates `work/`, so you always
start from a clean project — a fast loop for confirming that any given
dependency resolves through Chainguard Libraries.
