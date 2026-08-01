# manifest-version-update-action

Update package.json and optionally package-lock.json to a specified version.

## Inputs

- `version`: version to write into package.json
- `package-json-path`: path to package.json (default: `package.json`)
- `package-lock-path`: path to package-lock.json (default: `package-lock.json`)
- `update-package-lock`: whether to update package-lock.json too (default: `true`)
- `working-directory`: directory containing the manifests (default: `.`)

## Outputs

- `packageJsonUpdated`: whether package.json was updated
- `packageLockUpdated`: whether package-lock.json was updated

## Example

```yaml
- uses: vscheuber/manifest-version-update-action@v1
  with:
    version: 1.2.3
```
