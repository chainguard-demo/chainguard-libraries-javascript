# npm — migrating an existing project

[`demo.sh`](demo.sh) shows how to move an **existing** npm project with a
committed `package-lock.json` onto
[Chainguard Libraries for JavaScript](https://edu.chainguard.dev/chainguard/libraries/javascript/).

The [`npm`](../npm/README.md) example starts from an empty project and resolves
fresh, which is the easy case. Real projects already have a lockfile whose
`resolved` URLs and `integrity` hashes point at the public npm registry, and
that lockfile determines where packages are fetched from — so pointing the
registry at Chainguard is not enough on its own.

## The problem

`npm ci` installs strictly from `package-lock.json` and honors the `resolved`
URL recorded for each package. If those URLs point at `registry.npmjs.org`,
`npm ci` keeps downloading from the public registry even after you set
`registry=https://libraries.cgr.dev/javascript/`. To actually consume Chainguard
Libraries you have to deal with the lockfile.

## Two ways to migrate

### 1. Rewrite the lockfile in place with `chainctl` (what `demo.sh` runs)

Keep the lockfile and the exact versions it already pins — just rewrite its
`resolved` URLs and `integrity` hashes to point at Chainguard Libraries, then
install strictly from it:

```bash
GROUP="${CHAINGUARD_JAVASCRIPT_IDENTITY_ID%%/*}"   # group UIDP, before the /
chainctl libraries update-hashes --replace --parent "$GROUP" package-lock.json
npm ci
```

This is the right path for an existing project: every package comes from
Chainguard Libraries while the pinned versions stay exactly as they were, so the
migration changes *where* packages come from without changing *which* versions
you get. Use it in CI and anywhere reproducible, pinned versions matter.

`--replace` swaps the npm integrity hash for the Chainguard one
(`package-lock.json` stores a single hash per package). `--parent` is the group
UIDP, taken from the identity ID; it lets `update-hashes` mint a libraries-scoped
token from your active `chainctl` session non-interactively. `update-hashes`
authenticates with that `chainctl` session (see the repo
[Prerequisites](../README.md#prerequisites)), **not** the pull token — the pull
token only authenticates the registry fetch that `npm ci` then performs.

If a package in the lockfile is not mirrored in Chainguard Libraries,
`update-hashes` cannot compute a Chainguard hash for it and fails with a list of
offenders. That is a different mechanism from the registry's `/javascript-upstream/`
fallback, which only kicks in at `npm ci` fetch time. See `--fallback-registry-url`
in `chainctl libraries update-hashes --help` for how to handle unmirrored
packages.

### 2. Fresh re-resolve

If you do not need to preserve exact transitive versions, delete the lockfile
and let npm re-resolve the whole tree through the Chainguard registry:

```bash
rm -f package-lock.json
npm install --legacy-peer-deps
```

Simpler, but transitive versions may move, since npm resolves against what the
registry offers now rather than what the old lockfile pinned.

`--legacy-peer-deps` is a realistic default here. A fresh re-resolve of a large
dependency tree can surface latent peer-dependency conflicts that `npm ci` hides
by installing the committed tree verbatim — for example, Apache Superset pins
`storybook@8.6.17` while `@storybook/addon-actions` wants `^8.6.18`. The flag
relaxes peer resolution the way older npm did. It is not a Chainguard concern:
resolution and downloads still go through `libraries.cgr.dev`. `demo.sh` includes
this path as a commented block but does not run it.

## Configuration

| What | Value |
|---|---|
| Config file | project `.npmrc` |
| Registry | `https://libraries.cgr.dev/javascript/` (trailing slash matters) |
| Auth mechanism | base64-encoded `identity:token` in `_auth`, scoped to the whole host |

The auth entry is scoped to `//libraries.cgr.dev/` rather than
`//libraries.cgr.dev/javascript/` so it also covers the `/javascript-upstream/`
path the registry redirects to when upstream fallback serves a package that is
not mirrored yet. Chainguard Libraries customer organizations default to having
that fallback enabled, so no npmjs.org registry needs to be configured in the
project — but it is a configurable org-level default, not guaranteed behavior.

## Run it

The primary path needs both a pull token (for the `npm ci` registry fetch) and
an active `chainctl` session (for `update-hashes`). Minting the pull token
already requires an active session, so export the pull token first (see
[`../tools/README.md`](../tools/README.md)) and run the demo in the same shell:

```bash
eval "$(chainctl auth pull-token --output env --repository=javascript)"
./demo.sh
```

The script prints where the lockfile resolves from before and after the
migration, so you can see the `resolved` URLs move from `registry.npmjs.org` to
`libraries.cgr.dev` while the versions stay fixed.

## Iterate

To test a different dependency set, edit the `npm pkg set dependencies.*` line
near the top of `demo.sh` and run it again. Each run wipes and recreates
`work/`, so you always start from a clean project.
