# Bun — direct access to Chainguard Libraries

[`demo.sh`](demo.sh) shows how to point Bun at
[Chainguard Libraries for JavaScript](https://edu.chainguard.dev/chainguard/libraries/javascript/)
and install packages directly from `libraries.cgr.dev`.

## What the script does

Running `demo.sh` creates a fresh, throwaway Bun project in a git-ignored
`work/` subdirectory, applies the registry and authentication configuration,
and installs a couple of packages so you can watch them resolve through
Chainguard Libraries.

The project is a **hollow shell** — it has no application code and does
nothing on its own. Its only job is to prove that the configuration is correct
and that dependency resolution works. That said, the configuration steps are
exactly what you would apply to a real Bun project, so treat the script as a
working template rather than a throwaway.

## Configuration

| What | Value |
|---|---|
| Config file | `bunfig.toml` |
| Registry | `[install.registry] url = "https://libraries.cgr.dev/javascript/"` |
| Auth mechanism | `username` / `password` in the same `[install.registry]` block |

## Run it

Export a pull token first (see [`../tools/README.md`](../tools/README.md)):

```bash
eval "$(chainctl auth pull-token --output env --repository=javascript)"
./demo.sh
```

## Iterate

To test a different package, edit the `bun add` line near the end of
`demo.sh` and run it again. Each run wipes and recreates `work/`, so you always
start from a clean project — a fast loop for confirming that any given
dependency resolves through Chainguard Libraries.
