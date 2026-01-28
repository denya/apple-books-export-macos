# Apple Books Export - macOS App

A native macOS application for exporting highlights, bookmarks, and notes from Apple Books.

## Features

- 📚 Browse all books with annotations from Apple Books
- 🔍 Search and filter by book title, author, type, and color
- ✅ Select specific books and annotations to export
- 📤 Export to multiple formats:
  - **HTML** - Self-contained with search functionality and dark mode
  - **Markdown** - With YAML frontmatter and emoji indicators
  - **JSON** - Structured data with metadata
  - **CSV** - Spreadsheet-compatible format
- 🎨 Color-coded annotations (yellow, green, blue, pink, purple, underline)
- 🚀 Fast and native (built with SwiftUI and Swift Package Manager)

## Requirements

- macOS 14.0 or later
- Apple Books with at least one highlighted book

## Development

### Quick Start

```bash
# Build and run
APP_NAME=AppleBooksExport \
BUNDLE_ID=com.applebooksexport.macos \
Scripts/compile_and_run.sh

# Just build
swift build

# Run tests
swift test
```

### Project Structure

```
apple-books-export-macos/
├── Package.swift              # SPM manifest
├── version.env                # Version configuration
├── Sources/
│   └── AppleBooksExport/
│       ├── Models/            # Data models
│       ├── ViewModels/        # Business logic
│       ├── Views/             # SwiftUI views
│       ├── Database/          # SQLite access with GRDB
│       ├── Exporters/         # HTML, Markdown, JSON, CSV
│       └── main.swift         # App entry point
└── Scripts/
    ├── compile_and_run.sh     # Dev loop: build + launch
    ├── package_app.sh         # Create .app bundle
    └── sign-and-notarize.sh   # Distribution build
```

### Build Scripts

- **`compile_and_run.sh`** - Fast development loop: kills old app, rebuilds, launches
- **`package_app.sh`** - Creates signed `.app` bundle for distribution
- **`sign-and-notarize.sh`** - Notarizes for public distribution

### Environment Variables

```bash
export APP_NAME="AppleBooksExport"
export BUNDLE_ID="com.applebooksexport.macos"
export MACOS_MIN_VERSION="14.0"
export ARCHES="arm64 x86_64"  # Universal binary
export SIGNING_MODE="adhoc"    # or set APP_IDENTITY for release
```

## Architecture

### Data Flow

1. **AppleBooksDatabase** queries SQLite databases:
   - `~/Library/Containers/com.apple.iBooksX/Data/Documents/AEAnnotation/*.sqlite`
   - `~/Library/Containers/com.apple.iBooksX/Data/Documents/BKLibrary/*.sqlite`

2. **BooksViewModel** manages UI state:
   - Book selection
   - Annotation filtering
   - Search

3. **ExportViewModel** handles export:
   - Format selection
   - File save panel
   - Progress tracking

4. **Exporters** generate output:
   - HTMLExporter - Self-contained HTML with search
   - MarkdownExporter - YAML frontmatter + markdown
   - JSONExporter - Structured JSON
   - CSVExporter - Denormalized CSV rows

### Database Schema

Apple Books uses Core Data with SQLite. Key tables:

- **ZAEANNOTATION** - Annotations (highlights, bookmarks, notes)
  - `ZANNOTATIONSELECTEDTEXT` - Highlighted text
  - `ZANNOTATIONNOTE` - User note
  - `ZANNOTATIONSTYLE` - Color code (0-5)
  - `ZANNOTATIONCREATIONDATE` - Apple epoch timestamp

- **ZBKLIBRARYASSET** - Book metadata
  - `ZTITLE` - Book title
  - `ZAUTHOR` - Book author
  - `ZGENRE` - Book genre

### Date Conversion

Apple uses epoch of 2001-01-01 (not Unix epoch). Convert with:

```swift
let unixTimestamp = appleTimestamp + 978307200
```

### Annotation Style Mapping

```
0 → Underline
1 → Green
2 → Blue
3 → Yellow (default)
4 → Pink
5 → Purple
```

## Distribution

### Ad-hoc Signing (Local Testing)

```bash
SIGNING_MODE=adhoc \
ARCHES="arm64 x86_64" \
Scripts/package_app.sh release
```

### Developer ID Signing (Public Distribution)

```bash
# Set credentials
export APP_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
export APP_STORE_CONNECT_API_KEY_P8="/path/to/AuthKey_KEYID.p8"
export APP_STORE_CONNECT_KEY_ID="YOUR_KEY_ID"
export APP_STORE_CONNECT_ISSUER_ID="YOUR_ISSUER_ID"

# Build and notarize
ARCHES="arm64 x86_64" Scripts/package_app.sh release
Scripts/sign-and-notarize.sh
```

Creates: `AppleBooksExport-1.0.0.zip` (notarized and stapled)

### GitHub Release

```bash
git tag v1.0.0
git push origin v1.0.0

gh release create v1.0.0 AppleBooksExport-1.0.0.zip \
  --title "Apple Books Export 1.0.0" \
  --notes "Initial release"
```

## Troubleshooting

### No databases found

Make sure you've highlighted at least one book in Apple Books. The databases are only created after you make your first annotation.

### Build fails with "No such module 'GRDB'"

```bash
swift package resolve
swift build
```

### App doesn't launch

```bash
# Check for running instances
pkill -9 AppleBooksExport

# Rebuild
Scripts/compile_and_run.sh
```

### Permissions error reading databases

The app uses App Sandbox with `com.apple.security.files.user-selected.read-write` entitlement. Databases are in your home directory, which should be accessible.

## Related Projects

- [apple-books-export](../apple-books-export/) - TypeScript CLI version
- [GRDB.swift](https://github.com/groue/GRDB.swift) - SQLite toolkit

## License

MIT
