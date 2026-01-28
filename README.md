# Apple Books Export for macOS

A native macOS application to export your Apple Books library, including highlights, bookmarks, and personal notes.

## Features

- 📚 Browse all books in your Apple Books library
- 🔍 Search and filter annotations by color, type, and book
- ✅ Select specific books or annotations for export
- 📤 Export to multiple formats: HTML, Markdown, JSON, CSV
- 🌓 Dark mode support (HTML exports)
- 🎨 Color-coded highlights matching Apple Books styles
- ⌨️ Full keyboard navigation and accessibility support
- 🖥️ Native macOS design with modern materials and effects

## Download

### Latest Build
Download the latest version: [Apple Books Export - Latest](https://github.com/denya/apple-books-export-macos/releases/latest/download/AppleBooksExport.dmg)

### Tagged Releases
View all releases: [Releases Page](https://github.com/denya/apple-books-export-macos/releases)

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Books with existing library and annotations

## Installation

1. Download the DMG file from the link above
2. Open the DMG file
3. Drag Apple Books Export to your Applications folder
4. Launch the app
5. On first launch, right-click the app and select "Open" (macOS Gatekeeper requirement for unsigned apps)
6. The app will automatically locate your Apple Books databases

## How It Works

Apple Books Export reads directly from Apple Books' SQLite databases:
- **Annotations:** `~/Library/Containers/com.apple.iBooksX/Data/Documents/AEAnnotation/`
- **Library:** `~/Library/Containers/com.apple.iBooksX/Data/Documents/BKLibrary/`

The app uses [GRDB.swift](https://github.com/groue/GRDB.swift) for efficient database access and maintains a read-only connection to your Apple Books data.

## Export Formats

### HTML
Self-contained HTML file with:
- Built-in search functionality
- Dark mode toggle
- Styled annotation cards
- Color-coded highlights
- Responsive design

### Markdown
Clean markdown format with:
- YAML frontmatter with metadata
- Hierarchical structure by book
- Annotation metadata (color, type, location)
- Easy to import into note-taking apps

### JSON
Structured data export for programmatic use:
- Complete annotation metadata
- Book information
- Creation and modification timestamps
- Suitable for data analysis or custom processing

### CSV
Spreadsheet-compatible format for data analysis:
- One row per annotation
- All metadata fields included
- Compatible with Excel, Numbers, Google Sheets
- Easy filtering and sorting

## Usage

### Basic Workflow

1. **Browse Books:** View all books in your Apple Books library in the sidebar
2. **Search & Filter:** Use the search bar and color filters to find specific annotations
3. **Select Content:**
   - Click "Select" to enter selection mode
   - Choose individual books or annotations
   - Use "All books" to work with all annotations
4. **Export:** Click "Export" and choose your format
5. **Save:** Choose a destination and filename for your export

### Keyboard Shortcuts

- **⌘A** - Select All (in selection mode)
- **⌘E** - Export selected items
- **⌘F** - Focus search field
- **⌘W** - Close window
- **⌘Q** - Quit application

### Selection Modes

- **Select Books:** Choose one or more books to export all their annotations
- **Select Annotations:** Choose specific annotations across multiple books
- **All Books Mode:** View and filter all annotations across your entire library

## Privacy

This application runs entirely on your local machine. No data is sent to external servers. All database reads are performed locally, and your Apple Books data never leaves your Mac.

## Building from Source

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Build Instructions

```bash
# Clone the repository
git clone https://github.com/denya/apple-books-export-macos.git
cd apple-books-export-macos

# Build with Swift Package Manager
swift build -c release

# Or open in Xcode
open Package.swift
```

### Universal Binary

To build a universal binary (Intel + Apple Silicon):

```bash
# Build for Intel
swift build -c release --arch x86_64

# Build for Apple Silicon
swift build -c release --arch arm64

# Create universal binary
lipo -create \
  .build/x86_64-apple-macosx/release/AppleBooksExport \
  .build/arm64-apple-macosx/release/AppleBooksExport \
  -output AppleBooksExport-universal

# Verify architectures
lipo -info AppleBooksExport-universal
```

## Project Structure

```
apple-books-export-macos/
├── Sources/
│   └── AppleBooksExport/
│       ├── App/                    # Application entry point
│       ├── Views/                  # SwiftUI views
│       ├── ViewModels/            # View models (MVVM)
│       ├── Models/                # Data models
│       ├── Database/              # Database access layer
│       └── Export/                # Export formatters
├── Package.swift                  # Swift Package Manager manifest
└── README.md
```

## Architecture

The app follows a clean MVVM (Model-View-ViewModel) architecture:

- **Models:** Pure data structures representing books, annotations, and export configurations
- **Database Layer:** GRDB.swift-based data access with type-safe queries
- **ViewModels:** Business logic, state management, and coordination
- **Views:** SwiftUI views with accessibility support and modern materials

## Accessibility

Apple Books Export is designed with accessibility in mind:

- Full VoiceOver support with descriptive labels
- Dynamic Type support (scales with system text size)
- Keyboard navigation throughout the app
- High contrast mode support
- Reduce Motion support
- Color-blind friendly design (color + text labels)

## Technology Stack

- **SwiftUI** - Modern declarative UI framework
- **GRDB.swift** - Efficient SQLite database access
- **Swift Package Manager** - Dependency management
- **macOS Materials** - Native translucent effects
- **Combine** - Reactive programming for state management

## Known Limitations

- The app requires Apple Books to be installed and have an existing library
- Annotations are read-only (the app does not modify your Apple Books data)
- Some PDF annotations may not include page numbers if not available in the database
- Deleted books may still appear if their annotations remain in the database

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (if available)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for code style consistency
- Add accessibility labels to all interactive elements
- Test with VoiceOver and Dynamic Type

## License

MIT License - See [LICENSE](LICENSE) file for details

## Acknowledgments

- Built with [GRDB.swift](https://github.com/groue/GRDB.swift) by Gwendal Roué
- Uses Apple Books' public database structure (undocumented but stable)
- Inspired by the need to preserve and analyze reading highlights
- Thanks to the Apple Books team for creating a robust annotation system

## Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/denya/apple-books-export-macos/issues) page for existing reports
2. Create a new issue with:
   - macOS version
   - App version
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant error messages or screenshots

## Roadmap

Future improvements planned:

- [ ] Export templates customization
- [ ] Batch export automation
- [ ] Statistics dashboard (most highlighted books, reading patterns)
- [ ] iCloud sync support (for sharing exports across devices)
- [ ] PDF export format
- [ ] Annotation search across all books
- [ ] Tag-based organization
- [ ] Integration with note-taking apps (Obsidian, Notion, etc.)

---

**Note:** This is an unofficial third-party application. It is not affiliated with, endorsed by, or sponsored by Apple Inc.
