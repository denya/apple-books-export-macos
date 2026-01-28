import SwiftUI

struct ContentView: View {
    @StateObject private var booksViewModel = BooksViewModel()
    @StateObject private var exportViewModel = ExportViewModel()
    @State private var selectedBookId: String?
    @State private var showingExportPanel = false
    @State private var showAllAnnotations = true

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            BookListView(
                viewModel: booksViewModel,
                selectedBookId: $selectedBookId
            )
            .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 600)
        } detail: {
            if showAllAnnotations {
                AllAnnotationsView(viewModel: booksViewModel)
            } else if let bookId = selectedBookId,
                      let book = booksViewModel.books.first(where: { $0.id == bookId }) {
                AnnotationDetailView(
                    book: book,
                    viewModel: booksViewModel
                )
            } else {
                Text("Select a book to view annotations")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Toggle(isOn: $showAllAnnotations) {
                    Label("All Annotations", systemImage: showAllAnnotations ? "list.bullet" : "book")
                }
                .help("Toggle between all annotations view and single book view")
            }

            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingExportPanel = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(booksViewModel.selectedBookIds.isEmpty)
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
