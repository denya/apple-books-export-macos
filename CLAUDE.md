# Apple Books Export - macOS App

## Build System

SPM-only workflow (no Xcode project files):
- `swift build` - Debug build
- `swift build -c release` - Release build
- `Scripts/compile_and_run.sh` - Kill, rebuild, launch app
- `Scripts/package_app.sh` - Create signed .app bundle
- Requires `APP_NAME` and `BUNDLE_ID` environment variables
- Add `-parse-as-library` swift flag for @main apps

## Apple Books Database Access

Database paths:
- Annotations: `~/Library/Containers/com.apple.iBooksX/Data/Documents/AEAnnotation/AEAnnotation_*.sqlite`
- Library: `~/Library/Containers/com.apple.iBooksX/Data/Documents/BKLibrary/BKLibrary*.sqlite`

Key details:
- Apple epoch: 2001-01-01 (add 978307200 to convert to Unix timestamp)
- Annotation styles: 0=underline, 1=green, 2=blue, 3=yellow, 4=pink, 5=purple
- JOIN across two databases: `ATTACH DATABASE ? AS library`
- Read-only access with `DatabaseQueue(path:)`

## Swift 6 Concurrency

Patterns used:
- Avoid `Task.detached` with captured `self` (region isolation error)
- Use synchronous database access, wrap in Task at call site if needed
- `@MainActor` for ViewModels with `@Published` properties
- Run GRDB queries on background thread at call boundary, not in class method

## UI Patterns

- SwiftUI materials: `.ultraThinMaterial`, `.thinMaterial` for backgrounds
- Optional List selection needs explicit Button for nil tag (SwiftUI bug)
- Multi-select: TapGesture with `.modifiers(.command)` and `.modifiers(.shift)`
- Accessibility: add labels, hints, values, and traits to all interactive elements

## Entitlements

Required for Apple Books access:
- `com.apple.security.temporary-exception.files.absolute-path.read-only` for Books containers
- `com.apple.security.files.user-selected.read-write` for export save panel

## Development Workflow

Quick iteration:
```bash
APP_NAME=AppleBooksExport BUNDLE_ID=com.applebooksexport.macos Scripts/compile_and_run.sh
```

The script handles:
- Killing existing app instances
- Building release binary
- Creating .app bundle with code signing
- Launching and verifying the app is running
