# Tools and access setup for Chainguard Libraries for JavaScript

Shared setup for consuming
[Chainguard Libraries for JavaScript](https://edu.chainguard.dev/chainguard/libraries/javascript/)
directly from `libraries.cgr.dev`.

Creating an entitlement and a pull token is the same regardless of which
package manager you use. That common part is documented here. The registry
configuration that *does* differ — `.npmrc`, `bunfig.toml`, Yarn config, and so
on — lives with each package manager's own example.

For the authoritative, always-current reference, see the Chainguard Academy
docs:

* [Chainguard Libraries](https://edu.chainguard.dev/chainguard/libraries/) —
  product overview, access, verification, and repository-manager integrations
* [Chainguard Libraries for JavaScript — global configuration](https://edu.chainguard.dev/chainguard/libraries/javascript/global-configuration/) —
  configuring npm, pnpm, Yarn, and Bun on your workstation
* [Chainguard Libraries for JavaScript — build configuration](https://edu.chainguard.dev/chainguard/libraries/javascript/build-configuration/) —
  the per-tool "Minimal example project" sections that each `demo.sh` implements

## In this folder

| Resource | Purpose |
|---|---|
| [`access-examples.md`](access-examples.md) | `chainctl` command examples — entitlements, pull tokens, and policies. Start here to set up credentials. |

## Authentication

Direct access to the Chainguard Libraries for JavaScript repository uses a
Chainguard Libraries pull token, exported as environment variables:

```bash
eval "$(chainctl auth pull-token --output env --repository=javascript)"
```

This sets `CHAINGUARD_JAVASCRIPT_IDENTITY_ID` and `CHAINGUARD_JAVASCRIPT_TOKEN`,
which the per-tool registry configuration reads. See
[`access-examples.md`](access-examples.md) for the full set of `chainctl`
commands, including entitlements, organization-scoped tokens, and policies.

## Registry

All package managers point at the single JavaScript registry endpoint:

```
https://libraries.cgr.dev/javascript/
```

## Per-tool configuration

The registry endpoint and pull-token credentials are consumed differently by
each package manager. Each example applies the identity and token from the pull
token, but the mechanism varies:

| Package manager | Configuration file | Auth mechanism |
|---|---|---|
| [npm](../npm/README.md) | `.npmrc` | base64-encoded `identity:token` in `_auth` |
| [pnpm](../pnpm/README.md) | `.npmrc` | username / password |
| [Yarn Berry (v4+)](../yarn-berry/README.md) | `.yarnrc.yml` | `npmAuthIdent` (`identity:token`) |
| [Yarn Classic (v1)](../yarn-classic/README.md) | `.npmrc` | base64-encoded `identity:token` in `_auth` |
| [Bun](../bun/README.md) | `bunfig.toml` | username / password |

See each package manager's folder README for its exact configuration and a
runnable `demo.sh`.

## Repository managers

The examples in this repository all use **direct access** to
`libraries.cgr.dev/javascript/`. In many organizations a repository manager
sits in front of Chainguard Libraries instead, caching packages through to the
Chainguard registry (pull-through caching). Supported options include Sonatype
Nexus, JFrog Artifactory, Cloudsmith, Harbor, Amazon ECR, and Google Artifact
Registry.

In that setup each package manager points at the repository manager's own URL
and authenticates with that manager's credentials rather than a Chainguard pull
token — the per-tool config file and auth mechanism are otherwise the same as
the direct-access examples here. Each package manager's `demo.sh` includes a
commented Nexus example next to its registry configuration that shows the
registry swap; adapt the URL and credentials to your own repository manager.
Configuration is specific to each repository manager, so follow their
documentation together with the Chainguard docs:

* [Chainguard Libraries](https://edu.chainguard.dev/chainguard/libraries/) —
  overview of repository-manager integrations
* [Chainguard Libraries for JavaScript — global configuration](https://edu.chainguard.dev/chainguard/libraries/javascript/global-configuration/)
