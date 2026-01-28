import SwiftUI

struct ContentView: View {
    @StateObject private var booksViewModel = BooksViewModel()
    @StateObject private var exportViewModel = ExportViewModel()
    @State private var selectedBookId: String?
    @State private var showingExportPanel = false

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            BookListView(
                viewModel: booksViewModel,
                selectedBookId: $selectedBookId
            )
            .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 600)
        } detail: {
            let booksToShow = booksViewModel.getBooksForView(selectedBookId: selectedBookId)
            AllAnnotationsView(
                viewModel: booksViewModel,
                books: booksToShow,
                title: selectedBookId == nil ? "All Books" : nil
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
                .help("Toggle selection mode for export")
            }

            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingExportPanel = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingExportPanel) {
            ExportPanel(
                booksViewModel: booksViewModel,
                exportViewModel: exportViewModel,
                isPresented: $showingExportPanel
            )
        }
        .task {
            await booksViewModel.loadBooks()
        }
    }
}
