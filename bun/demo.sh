#!/usr/bin/env bash
# Create a throwaway Bun project, configure direct access to Chainguard
# Libraries, and install packages to prove resolution works. See ./README.md.
# Requires the pull-token env vars — see ../tools/README.md.
set -euo pipefail

: "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"
: "${CHAINGUARD_JAVASCRIPT_TOKEN:?Run: eval \"\$(chainctl auth pull-token --output env --repository=javascript)\" — see ../tools/README.md}"

cd "$(dirname "$0")"
rm -rf work && mkdir work && cd work

bun init -y >/dev/null

# Registry and auth via bunfig.toml (username / password).
cat > bunfig.toml <<EOF
[install.registry]
url = "https://libraries.cgr.dev/javascript/"
username = "${CHAINGUARD_JAVASCRIPT_IDENTITY_ID}"
password = "${CHAINGUARD_JAVASCRIPT_TOKEN}"
EOF

# Alternative: through a Nexus repository manager. Point the registry url in
# bunfig.toml at your Nexus npm repository and authenticate with your Nexus
# credentials instead of the pull-token username/password. Example:
#   url = "http://localhost:8081/repository/javascript-chainguard/"

echo "Configured Bun registry and auth in bunfig.toml"

# Swap in any dependency you want to test, then re-run this script.
bun add commander@4.1.1 picocolors@1.1.1
bun pm ls
