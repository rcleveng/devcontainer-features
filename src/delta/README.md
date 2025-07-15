
# Delta Pager (delta)

Installs the delta pager for git

## Example Usage

```json
"features": {
    "ghcr.io/rcleveng/devcontainer-features/delta:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The version of delta to install | string | latest |

Available versions of the delta pager: https://github.com/dandavison/delta/releases
Github Homepage: https://github.com/dandavison/delta

## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions with the `apt` package manager installed as well as
Alpine with apk.

`bash` is required to execute the `install.sh` script.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/rcleveng/devcontainer-features/blob/main/src/delta/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
