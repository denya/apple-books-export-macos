import SwiftUI

struct ExportPanel: View {
    @ObservedObject var booksViewModel: BooksViewModel
    @ObservedObject var exportViewModel: ExportViewModel
    @Binding var isPresented: Bool

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

                HStack {
                    Label("\(booksViewModel.selectedBookIds.count) books", systemImage: "book")
                    Spacer()
                    Label("\(booksViewModel.selectedAnnotationCount) annotations", systemImage: "note.text")
                }
                .font(.body)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Progress
            if exportViewModel.isExporting {
                ProgressView("Exporting...")
                    .progressViewStyle(.linear)
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
        .frame(width: 500, height: 300)
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
            let books = booksViewModel.selectedBooksWithFilteredAnnotations
            _ = try await exportViewModel.export(
                books: books,
                format: exportViewModel.selectedFormat
            )
            isPresented = false
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
