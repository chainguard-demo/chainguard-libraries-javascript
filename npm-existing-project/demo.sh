#!/usr/bin/env bash
# Migrate an EXISTING npm project with a committed package-lock.json to
# Chainguard Libraries, preserving the exact versions the lockfile already pins.
# Unlike ../npm/demo.sh, which starts from an empty project and resolves fresh,
# this models the common real-world case: a project that already has a lockfile
# whose `resolved` URLs point at the public npm registry. See ./README.md.
# Requires the pull-token env vars AND an active chainctl session — see
# ../tools/README.md.
set -euo pipefail

: "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"
: "${CHAINGUARD_JAVASCRIPT_TOKEN:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"

cd "$(dirname "$0")"
rm -rf work && mkdir work && cd work

# --- Simulate an existing project ------------------------------------------
# Create a small project and generate a package-lock.json from the PUBLIC npm
# registry, so its `resolved` URLs point at registry.npmjs.org — exactly the
# state of a real project you are about to migrate.
npm init -y >/dev/null
npm pkg set dependencies.commander=4.1.1 dependencies.picocolors=1.1.1 >/dev/null
npm install --package-lock-only >/dev/null
echo "Before migration, lockfile resolves from:"
grep -m1 '"resolved"' package-lock.json

# --- Point npm at Chainguard Libraries -------------------------------------
# Registry (trailing slash matters). Auth = base64 identity:token in _auth,
# scoped to the whole host (not just /javascript/) so the upstream fallback
# works: unmirrored packages are served via /javascript-upstream/ and still need
# these credentials. Chainguard Libraries customer orgs default to having this
# fallback enabled, so no npmjs.org registry needs to be configured here — but it
# is a configurable org default, not guaranteed behavior.
npm config set registry https://libraries.cgr.dev/javascript/ --location=project
JS_AUTH="$(printf '%s' "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID}:${CHAINGUARD_JAVASCRIPT_TOKEN}" | base64 | tr -d '\n')"
npm config set //libraries.cgr.dev/:_auth "${JS_AUTH}" --location=project

# --- Migrate: rewrite the lockfile in place with chainctl ------------------
# `npm ci` installs strictly from package-lock.json and honors the `resolved`
# URLs baked into it, so on its own it would keep pulling from the public
# registry. Rather than delete the lockfile and re-resolve (which can move
# transitive versions), rewrite its `resolved` URLs and `integrity` hashes in
# place so every entry points at Chainguard Libraries while the pinned versions
# stay exactly as they were.
#
# --replace swaps the npm integrity hash for the Chainguard one
# (package-lock.json stores a single hash per package). --parent is the group
# UIDP, taken from the identity ID (everything before the first /); it lets
# update-hashes mint a libraries-scoped token from your active chainctl session
# non-interactively. update-hashes authenticates with that chainctl session, NOT
# the pull token — the pull token only authenticates the registry fetch that
# `npm ci` performs below.
GROUP="${CHAINGUARD_JAVASCRIPT_IDENTITY_ID%%/*}"
chainctl libraries update-hashes --replace --parent "$GROUP" package-lock.json

echo "After migration, lockfile resolves from:"
grep -m1 '"resolved"' package-lock.json

# --- Install strictly from the rewritten lockfile --------------------------
# `npm ci` now fetches the same pinned versions from Chainguard Libraries and
# verifies each download against the Chainguard integrity hashes just written.
npm ci
npm ls

# --- Alternative: fresh re-resolve against Chainguard Libraries -------------
# If you do not need to preserve exact transitive versions, delete the lockfile
# and let npm re-resolve the whole tree through the Chainguard registry instead:
#
#   rm -f package-lock.json
#   npm install --legacy-peer-deps
#
# Simpler, but transitive versions may move, since npm resolves against what the
# registry offers now rather than what the old lockfile pinned. --legacy-peer-deps
# is a realistic default: a fresh re-resolve of a large tree can surface latent
# peer-dependency conflicts that `npm ci` hides by installing the committed tree
# verbatim (for example, Apache Superset pins storybook 8.6.17 while
# @storybook/addon-actions wants ^8.6.18). It is not a Chainguard concern —
# resolution and downloads still go through libraries.cgr.dev.
#
# --- Alternative: through a repository manager -----------------------------
# Point the registry at your Nexus/Artifactory/etc. npm repository and
# authenticate with that manager's credentials instead of the pull-token auth:
#   npm config set registry http://localhost:8081/repository/javascript-chainguard/ --location=project
