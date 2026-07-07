#!/usr/bin/env bash
# Create a throwaway Yarn Classic (v1) project, configure direct access to
# Chainguard Libraries, and install packages to prove resolution works.
# See ./README.md. Requires the pull-token env vars — see ../tools/README.md.
set -euo pipefail

: "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"
: "${CHAINGUARD_JAVASCRIPT_TOKEN:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"

cd "$(dirname "$0")"
rm -rf work && mkdir work && cd work

echo "Using yarn version $(yarn --version)"
yarn init -y >/dev/null

# Yarn Classic's own `yarn config` does not handle auth reliably; write a
# project .npmrc instead. Auth is a base64-encoded identity:token in _auth.
token=$(printf '%s' "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID}:${CHAINGUARD_JAVASCRIPT_TOKEN}" | base64 | tr -d '\n')
cat > .npmrc <<EOF
registry=https://libraries.cgr.dev/javascript/
//libraries.cgr.dev/javascript/:_auth="${token}"
//libraries.cgr.dev/javascript/:always-auth=true
EOF

# Alternative: through a Nexus repository manager. Set the registry in .npmrc to
# your Nexus npm repository and authenticate with your Nexus credentials instead
# of the pull-token _auth. Example .npmrc registry line:
#   registry=http://localhost:8081/repository/javascript-chainguard/

echo "Configured registry and auth in .npmrc"

# Swap in any dependency you want to test, then re-run this script.
yarn add commander@4.1.1 picocolors@1.1.1
yarn list
