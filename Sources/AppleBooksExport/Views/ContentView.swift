import SwiftUI

struct ContentView: View {
    @StateObject private var booksViewModel = BooksViewModel()
    @StateObject private var exportViewModel = ExportViewModel()
    @State private var selectedBookIds: Set<String> = []
    @State private var showingExportPanel = false
    @State private var exportBooksOverride: [Book]?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            BookListView(
                viewModel: booksViewModel,
                selectedBookIds: $selectedBookIds,
                onExportBook: { book in
                    if selectedBookIds.contains(book.id) {
                        exportBooksOverride = nil
                    } else {
                        selectedBookIds = [book.id]
                        exportBooksOverride = [book]
                    }
                    showingExportPanel = true
                }
            )
            .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 600)
        } detail: {
            let booksToShow = booksViewModel.getBooksForView(selectedBookIds: selectedBookIds)
            AllAnnotationsView(
                viewModel: booksViewModel,
                books: booksToShow,
                title: selectedBookIds.isEmpty ? "All Books" : nil
            )
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { booksViewModel.toggleSelectionMode() }) {
                    Label(
                        booksViewModel.isSelectionMode ? "Done" : "Select",
                        systemImage: booksViewModel.isSelectionMode ? "checkmark" : "checkmark.circle"
                    )
                }
                .buttonStyle(.bordered)
                .help("Toggle selection mode for export")
                .keyboardShortcut("s", modifiers: .command)
            }

            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    exportBooksOverride = nil
                    showingExportPanel = true
                }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
                .disabled(booksViewModel.selectedBookIds.isEmpty && booksViewModel.selectedAnnotationIds.isEmpty && booksViewModel.isSelectionMode)
                .help("Export selected items")
                .keyboardShortcut("e", modifiers: .command)
            }
        }
        .sheet(isPresented: $showingExportPanel, onDismiss: {
            exportBooksOverride = nil
        }) {
            ExportPanel(
                booksViewModel: booksViewModel,
                exportViewModel: exportViewModel,
                isPresented: $showingExportPanel,
                booksOverride: exportBooksOverride,
                selectedBookIdsForView: selectedBookIds
            )
        }
        .task {
            await booksViewModel.loadBooks()
        }
    }
}
