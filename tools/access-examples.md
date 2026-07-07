# Example commands for Chainguard Libraries access

These `chainctl` commands set up and manage access to Chainguard Libraries for
JavaScript. They are the same across package managers.

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

Create pull token for access to JavaScript libraries for the chainguard.edu
organization, output environment variable commands, and pipe commands into a
shell script. Change the parent parameter to your organization name.

```shell
chainctl auth pull-token --output env --repository=javascript --parent=chainguard.edu > javascript-access.sh
```

Load the environment variables for use in a terminal.

```shell
source javascript-access.sh
```

Create new pull token for access to JavaScript libraries and set environment
variables:

```shell
eval $(chainctl auth pull-token --output env --repository=javascript --parent=chainguard.edu)
```

Create a policy with a 10-day cooldown and use it for JavaScript:

```shell
chainctl libraries policy create --name=cooldown-10 --cooldown-days=10
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
