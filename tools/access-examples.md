# Example commands for Chainguard Libraries access

These `chainctl` commands set up and manage access to Chainguard Libraries for
JavaScript. They are the same across package managers. The verify command also
checks local artifacts and saves their SBOMs and attestations.

List entitlements:

```sh
chainctl libraries entitlements list
```

Create entitlement for JavaScript with fallback to the upstream npm registry
activated:

```shell
chainctl libraries entitlements create --ecosystems=JAVASCRIPT --policy=CHAINGUARD_AND_UPSTREAM
```

Create pull token for access to JavaScript libraries and output environment
variable commands. Token valid for 30 days. The `--output env` form sets
`CHAINGUARD_JAVASCRIPT_IDENTITY_ID` and `CHAINGUARD_JAVASCRIPT_TOKEN`, the
variables the per-tool registry configuration reads.

```shell
chainctl auth pull-token --output env --repository=javascript
```

Evaluate the output directly to export both variables into the current shell:

```shell
eval "$(chainctl auth pull-token --output env --repository=javascript)"
```

Write the export commands to a script to source later:

```shell
chainctl auth pull-token --output env --repository=javascript > javascript-access.sh
source javascript-access.sh
```

If you are a member of multiple organizations the preceding example commands
must use the `--parent` parameter with the name of your organization:

```shell
eval "$(chainctl auth pull-token --output env --parent=chainguard.edu --repository=javascript)"
```

```shell
chainctl auth pull-token --output env --repository=javascript --parent=chainguard.edu > javascript-access.sh
```

Create a policy with a 10-day cooldown and use it for JavaScript:

```shell
chainctl libraries policy create --name=cooldown-10 --cooldown-days=10
chainctl libraries policy describe cooldown-10
chainctl libraries policy enable --policy=cooldown-10 --ecosystem=JAVASCRIPT --mode=ENFORCE
```

List policies

```shell
chainctl libraries policy list
```

List policy bindings to ecosystems:

```shell
chainctl libraries policy bindings list
```

## Verify artifacts and download attestations

`chainctl libraries verify` reports which packages were built from source by
Chainguard. It uses your `chainctl auth login` session rather than the pull-token
environment variables used by the package managers.

Verify a downloaded npm tarball and save its available companions:

```shell
chainctl libraries verify lodash-4.17.21.tgz --output-attestations
```

For this package, files are saved under `attestations/lodash/4.17.21/`:

- `lodash-provenance-4.17.21.sigstore` — the exact signed SLSA provenance bundle
  used to verify the package.
- `lodash-sbom-4.17.21.spdx.json` — the SPDX SBOM from the authenticated
  Chainguard endpoint. It is trusted based on that endpoint; its bytes are not
  cryptographically bound by the npm provenance.

Scoped packages use `attestations/@scope/name/version/`, with the unscoped name
in the file names. Only verified Chainguard builds produce companion files.
Missing SBOMs are skipped.

You can also save companions for dependencies in a supported lockfile. From the
repository root after running the npm demo:

```shell
chainctl libraries verify npm/work/package-lock.json --output-attestations
```

Lockfile downloads require verified provenance bound to the package the entry
will install. Ambiguous entries with multiple integrity hashes are skipped
unless their resolved URL identifies the Chainguard build. Installed
`node_modules` directories, npm caches, pnpm stores, and Yarn Classic caches also
support downloads.

See the [Chainguard Academy verification guide](https://edu.chainguard.dev/chainguard/libraries/policies-and-security/verification/#download-javascript-sboms-and-attestations)
for more details.
