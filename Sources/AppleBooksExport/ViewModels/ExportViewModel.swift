import Foundation
import SwiftUI
import AppKit

@MainActor
class ExportViewModel: ObservableObject {
    @Published var selectedFormat: ExportFormat = .html
    @Published var isExporting: Bool = false
    @Published var exportProgress: Double = 0
    @Published var lastExportedURL: URL?

    enum ExportFormat: String, CaseIterable, Identifiable {
        case html = "HTML"
        case markdown = "Markdown"
        case json = "JSON"
        case csv = "CSV"

        var id: String { rawValue }

        var fileExtension: String {
            switch self {
            case .html: return "html"
            case .markdown: return "md"
            case .json: return "json"
            case .csv: return "csv"
            }
        }

        var utType: String {
            switch self {
            case .html: return "public.html"
            case .markdown: return "net.daringfireball.markdown"
            case .json: return "public.json"
            case .csv: return "public.comma-separated-values-text"
            }
        }
    }

    func export(books: [Book], format: ExportFormat) async throws -> URL {
        isExporting = true
        exportProgress = 0

        defer {
            isExporting = false
        }

        // Create default filename with timestamp
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let defaultFilename = "apple-books-export-\(timestamp).\(format.fileExtension)"

        // Show save panel
        guard let url = await showSavePanel(defaultFilename: defaultFilename, format: format) else {
            throw ExportError.cancelled
        }

        // Export on background thread
        try await Task.detached {
            let content: String

            switch format {
            case .html:
                content = HTMLExporter.export(books: books)
            case .markdown:
                content = MarkdownExporter.export(books: books)
            case .json:
                content = try JSONExporter.export(books: books)
            case .csv:
                content = CSVExporter.export(books: books)
            }

            try content.write(to: url, atomically: true, encoding: .utf8)
        }.value

        await MainActor.run {
            self.lastExportedURL = url
            self.exportProgress = 1.0
        }

        // Auto-open the file
        NSWorkspace.shared.open(url)

        return url
    }

    private func showSavePanel(defaultFilename: String, format: ExportFormat) async -> URL? {
        await MainActor.run {
            let panel = NSSavePanel()
            panel.nameFieldStringValue = defaultFilename
            panel.canCreateDirectories = true
            panel.isExtensionHidden = false
            panel.allowedContentTypes = [.init(filenameExtension: format.fileExtension)!]
            panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first

            return panel.runModal() == .OK ? panel.url : nil
        }
    }
}

enum ExportError: LocalizedError {
    case cancelled
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Export cancelled"
        case .exportFailed(let message):
            return "Export failed: \(message)"
        }
    }
}
