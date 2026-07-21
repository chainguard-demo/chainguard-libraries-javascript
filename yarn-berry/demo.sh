#!/usr/bin/env bash
# Create a throwaway Yarn Berry (v4+) project, configure direct access to
# Chainguard Libraries, and install packages to prove resolution works.
# See ./README.md. Requires the pull-token env vars — see ../tools/README.md.
set -euo pipefail

: "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"
: "${CHAINGUARD_JAVASCRIPT_TOKEN:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"

cd "$(dirname "$0")"
rm -rf work && mkdir work && cd work

# Clear Yarn Berry's global npm-metadata cache — a stale entry can replay an
# old tarball URL and fail the fetch with HTTP 400. See ./README.md.
rm -rf "${HOME}/.yarn/berry/metadata"

# Pin the project to the current stable Yarn (Berry).
yarn set version stable
echo "Using yarn version $(yarn --version)"
yarn init -y >/dev/null

# Registry and auth (npmAuthIdent = identity:token). Yarn Berry matches
# npmRegistries keys exactly against the registry URL, so configure both the
# /javascript/ registry and the /javascript-upstream/ path that the registry
# redirects to for packages that are not mirrored yet.
authInfo="${CHAINGUARD_JAVASCRIPT_IDENTITY_ID}:${CHAINGUARD_JAVASCRIPT_TOKEN}"
yarn config set npmRegistryServer https://libraries.cgr.dev/javascript/
yarn config set 'npmRegistries["//libraries.cgr.dev/javascript/"].npmAuthIdent' "${authInfo}"
yarn config set 'npmRegistries["//libraries.cgr.dev/javascript/"].npmAlwaysAuth' true
yarn config set 'npmRegistries["//libraries.cgr.dev/javascript-upstream/"].npmAuthIdent' "${authInfo}"
yarn config set 'npmRegistries["//libraries.cgr.dev/javascript-upstream/"].npmAlwaysAuth' true

# Alternative: through a Nexus repository manager. Point npmRegistryServer at
# your Nexus npm repository and authenticate with your Nexus credentials instead
# of the npmAuthIdent. An http URL also needs unsafeHttpWhitelist. Example:
#   yarn config set npmRegistryServer http://localhost:8081/repository/javascript-chainguard/
#   yarn config set unsafeHttpWhitelist localhost

echo "Configured Yarn registry and auth"

# Swap in any dependency you want to test, then re-run this script.
yarn add commander@4.1.1 picocolors@1.1.1
yarn info --all --name-only || yarn info
