#!/usr/bin/env bash
# Create a throwaway npm project, configure direct access to Chainguard
# Libraries, and install packages to prove resolution works. See ./README.md.
# Requires the pull-token env vars — see ../tools/README.md.
set -euo pipefail

: "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"
: "${CHAINGUARD_JAVASCRIPT_TOKEN:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"

cd "$(dirname "$0")"
rm -rf work && mkdir work && cd work

npm init -y >/dev/null

# Registry — note the trailing slash.
npm config set registry https://libraries.cgr.dev/javascript/ --location=project

# Auth: base64-encoded identity:token in _auth. Scope it to the whole host (not
# just /javascript/) so it also covers the /javascript-upstream/ path that the
# registry redirects to for packages that are not mirrored yet.
token=$(printf '%s' "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID}:${CHAINGUARD_JAVASCRIPT_TOKEN}" | base64 | tr -d '\n')
npm config set //libraries.cgr.dev/:_auth "${token}" --location=project

# Alternative: through a Nexus repository manager. Point the registry at your
# Nexus npm repository and authenticate with your Nexus credentials instead of
# the pull-token auth. Example:
#   npm config set registry http://localhost:8081/repository/javascript-chainguard/ --location=project

echo "Configured npm registry and auth"

# Swap in any dependency you want to test, then re-run this script.
npm add commander@4.1.1 picocolors@1.1.1 d3@7.9.0
npm ls
