# chainguard-libraries-javascript

This repository contains tools and example configuration for
[Chainguard Libraries for JavaScript](https://edu.chainguard.dev/chainguard/libraries/javascript/).

The focus is on showing how to configure the common JavaScript package managers
to consume Chainguard Libraries directly from `libraries.cgr.dev`.

Each package manager has its own folder with a `demo.sh` script and a README.
The script creates a fresh throwaway project, applies that manager's registry
and authentication configuration, and installs a couple of packages so you can
confirm they resolve through Chainguard Libraries. The projects are hollow
shells with no application code — they exist only to prove the configuration
and dependency resolution work, but the config steps are a faithful template
for a real project.

| Folder | Package manager |
|---|---|
| [`tools`](tools/README.md) | Shared access setup — `chainctl` commands and authentication, the same for every package manager |
| [`npm`](npm/README.md) | npm |
| [`pnpm`](pnpm/README.md) | pnpm |
| [`yarn-berry`](yarn-berry/README.md) | Yarn Berry (v4+) |
| [`yarn-classic`](yarn-classic/README.md) | Yarn Classic (v1) |
| [`bun`](bun/README.md) | Bun |

## Prerequisites

* A Chainguard account with a JavaScript libraries entitlement
* [`chainctl`](https://edu.chainguard.dev/chainguard/chainctl/) installed and authenticated
* Node.js (current LTS) and the package manager you want to try

## Getting started

Set up access with the `chainctl` commands and authentication notes in
[`tools`](tools/README.md). Creating an entitlement and a pull token is
identical across package managers; only the per-tool registry configuration
differs, and that lives with each package manager's folder.

Once a pull token is exported into your shell:

```bash
eval "$(chainctl auth pull-token --output env --repository=javascript)"
```

run any package manager's demo, for example:

```bash
./npm/demo.sh
```

See each package manager's folder README for the per-tool configuration details
and how to swap in your own dependencies to test.

These examples all use direct access to `libraries.cgr.dev/javascript/`. If your
organization fronts Chainguard Libraries with a repository manager (Nexus,
Artifactory, Cloudsmith, Harbor, Amazon ECR, or Google Artifact Registry)
instead, see [Repository managers](tools/README.md#repository-managers) and the
[global configuration docs](https://edu.chainguard.dev/chainguard/libraries/javascript/global-configuration/).

## Resources

* [Chainguard Libraries product page](https://www.chainguard.dev/libraries)
* [Chainguard Libraries documentation](https://edu.chainguard.dev/chainguard/libraries/)
* [Chainguard Libraries for JavaScript documentation](https://edu.chainguard.dev/chainguard/libraries/javascript/)
* [Chainguard Libraries for JavaScript — global configuration](https://edu.chainguard.dev/chainguard/libraries/javascript/global-configuration/)
* [Chainguard Libraries for JavaScript — build configuration](https://edu.chainguard.dev/chainguard/libraries/javascript/build-configuration/) — the "Minimal example project" sections each `demo.sh` implements
* [Chainguard learning labs with more demos](https://edu.chainguard.dev/software-security/learning-labs/)
* [Chainguard Libraries for Java examples](https://github.com/chainguard-demo/chainguard-libraries-java)
* [Chainguard Libraries for Python examples](https://github.com/chainguard-demo/chainguard-libraries-python)
