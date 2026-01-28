import SwiftUI

struct BookListView: View {
    @ObservedObject var viewModel: BooksViewModel
    @Binding var selectedBookId: String?

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search books", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Books list
            if viewModel.isLoading {
                ProgressView("Loading books...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Error")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task {
                            await viewModel.loadBooks()
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredBooks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No books found")
                        .font(.headline)
                    Text("Try adjusting your filters or search")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedBookId) {
                    // "All books" item
                    HStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .foregroundStyle(.blue)
                        Text("All Books")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .tag(nil as String?)
                    .padding(.vertical, 2)

                    Divider()

                    // Individual books
                    ForEach(viewModel.filteredBooks) { book in
                        BookRowView(book: book, viewModel: viewModel)
                            .tag(book.id as String?)
                    }
                }
                .listStyle(.sidebar)
            }

            Divider()

            // Selection controls (only in selection mode)
            if viewModel.isSelectionMode {
                HStack {
                    Text("\(viewModel.selectedBookIds.count) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Select All") {
                        viewModel.selectAll()
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                    Button("Deselect All") {
                        viewModel.deselectAll()
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
                .padding(8)
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .navigationTitle("Books (\(viewModel.filteredBooks.count))")
    }
}
