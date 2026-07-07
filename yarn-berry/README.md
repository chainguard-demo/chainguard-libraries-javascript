# Yarn Berry (v4+) — direct access to Chainguard Libraries

[`demo.sh`](demo.sh) shows how to point Yarn Berry at
[Chainguard Libraries for JavaScript](https://edu.chainguard.dev/chainguard/libraries/javascript/)
and install packages directly from `libraries.cgr.dev`.

## What the script does

Running `demo.sh` pins the project to the current stable Yarn, creates a fresh,
throwaway project in a git-ignored `work/` subdirectory, applies the registry
and authentication configuration, and installs a couple of packages so you can
watch them resolve through Chainguard Libraries.

The project is a **hollow shell** — it has no application code and does
nothing on its own. Its only job is to prove that the configuration is correct
and that dependency resolution works. That said, the configuration steps are
exactly what you would apply to a real Yarn project, so treat the script as a
working template rather than a throwaway.

## Configuration

| What | Value |
|---|---|
| Config file | `.yarnrc.yml` |
| Registry | `npmRegistryServer: https://libraries.cgr.dev/javascript/` |
| Auth mechanism | `npmAuthIdent` (`identity:token`), with `npmAlwaysAuth: true` |

## The metadata-cache gotcha

Yarn Berry keeps a **global npm-metadata cache** at `~/.yarn/berry/metadata/`.
If that cache holds an entry from an earlier state of the registry, Yarn can
replay a stale tarball URL and the fetch fails with `HTTP 400 Bad Request` —
even though the registry serves the correct URL. The script clears this cache
before resolving:

```bash
rm -rf "${HOME}/.yarn/berry/metadata"
```

If you hit a 400 on a tarball fetch outside this script, clearing that
directory is the fix.

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
