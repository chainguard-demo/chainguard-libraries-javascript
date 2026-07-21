#!/usr/bin/env bash
# Create a throwaway pnpm project, configure direct access to Chainguard
# Libraries, and install packages to prove resolution works. See ./README.md.
# Requires the pull-token env vars — see ../tools/README.md.
set -euo pipefail

: "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"
: "${CHAINGUARD_JAVASCRIPT_TOKEN:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"

cd "$(dirname "$0")"
rm -rf work && mkdir work && cd work

pnpm init >/dev/null

# Registry — note the trailing slash.
pnpm config set registry https://libraries.cgr.dev/javascript/ --location=project

# Auth: username / password. pnpm treats _password as base64-encoded, so the
# token must be encoded before it is stored. Scope the auth to the whole host
# (not just /javascript/) so it also covers the /javascript-upstream/ path that
# the registry redirects to for packages that are not mirrored yet.
password=$(printf '%s' "${CHAINGUARD_JAVASCRIPT_TOKEN}" | base64 | tr -d '\n')
pnpm config set //libraries.cgr.dev/:username "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID}" --location=project
pnpm config set //libraries.cgr.dev/:_password "${password}" --location=project

# Alternative: through a Nexus repository manager. Point the registry at your
# Nexus npm repository and authenticate with your Nexus credentials instead of
# the pull-token auth. Example:
#   pnpm config set registry http://localhost:8081/repository/javascript-chainguard/ --location=project

echo "Configured pnpm registry and auth"

# Swap in any dependency you want to test, then re-run this script.
pnpm add commander@4.1.1 picocolors@1.1.1
pnpm list
