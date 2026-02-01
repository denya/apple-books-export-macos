import SwiftUI

struct ExportPanel: View {
    @ObservedObject var booksViewModel: BooksViewModel
    @ObservedObject var exportViewModel: ExportViewModel
    @Binding var isPresented: Bool
    let booksOverride: [Book]?
    let selectedBookIdsForView: Set<String>

    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Export Books")
                .font(.title)
                .fontWeight(.bold)

            Divider()

            // Format picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Export Format")
                    .font(.headline)

                Picker("Format", selection: $exportViewModel.selectedFormat) {
                    ForEach(ExportViewModel.ExportFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
            }

            Divider()

            // Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Export Summary")
                    .font(.headline)

                let bookCount = exportBooks.count
                let highlightCount = exportBooks.reduce(0) { $0 + $1.annotationCount }

                HStack {
                    Label("\(bookCount) books", systemImage: "book")
                    Spacer()
                    Label("\(highlightCount) highlights", systemImage: "highlighter")
                }
                .font(.body)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Progress
            if exportViewModel.isExporting {
                VStack(spacing: 8) {
                    ProgressView("Exporting...")
                        .progressViewStyle(.linear)
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            }

            // Buttons
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("Export") {
                    Task {
                        await performExport()
                    }
                }
                .keyboardShortcut(.return)
                .disabled(exportViewModel.isExporting)
            }
        }
        .padding(20)
        .frame(minWidth: 400, maxWidth: 600, minHeight: 300, maxHeight: 500)
        .background(.regularMaterial)
        .alert("Export Error", isPresented: $showingError) {
            Button("OK") {
                showingError = false
            }
        } message: {
            Text(errorMessage)
        }
    }

    private func performExport() async {
        do {
            _ = try await exportViewModel.export(
                books: exportBooks,
                format: exportViewModel.selectedFormat
            )
            isPresented = false
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }

    private var exportBooks: [Book] {
        if let booksOverride {
            return booksOverride
        }
        if booksViewModel.isSelectionMode {
            return booksViewModel.selectedBooksWithFilteredAnnotations
        }
        if !selectedBookIdsForView.isEmpty {
            return booksViewModel.filteredBooks.filter { selectedBookIdsForView.contains($0.id) }
        }
        return booksViewModel.filteredBooks
    }
}
