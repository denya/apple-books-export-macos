---
name: bump-version
description: Bump app version for Apple Books Export. Use when user says "bump version", "new release", "update version", or wants to release a new version. Creates git tag, updates README badge to new version DMG link.
user-invocable: true
---

# Bump Version

Release a new version of Apple Books Export.

## Workflow

1. **Get version**: If not provided, ask user for new version (format: X.Y.Z)
2. **Validate**: Ensure version follows semver format
3. **Update README**: Change download badge version and DMG link
4. **Commit**: Commit README changes with message "chore: Bump version to vX.Y.Z"
5. **Tag**: Create git tag `vX.Y.Z`
6. **Push**: Push commit and tag to trigger CI release build

## README Updates

Update these in README.md:

```markdown
# Before
[![Download](https://img.shields.io/badge/Download-vOLD-blue?style=for-the-badge&logo=apple)](https://github.com/denya/apple-books-export-macos/releases/download/OLD/AppleBooksExport.dmg)

# After
[![Download](https://img.shields.io/badge/Download-vNEW-blue?style=for-the-badge&logo=apple)](https://github.com/denya/apple-books-export-macos/releases/download/NEW/AppleBooksExport.dmg)
```

## Git Commands

```bash
# Commit README
git add README.md
git commit -m "chore: Bump version to vX.Y.Z"

# Create and push tag
git tag vX.Y.Z
git push && git push --tags
```

## After Push

CI will automatically:
1. Build universal binary (Intel + Apple Silicon)
2. Create signed DMG
3. Notarize with Apple
4. Create GitHub release with DMG attached
