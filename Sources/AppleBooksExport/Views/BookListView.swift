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

            // Filter controls
            FilterControlsView(viewModel: viewModel)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

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
                List(viewModel.filteredBooks, selection: $selectedBookId) { book in
                    BookRowView(book: book, viewModel: viewModel)
                        .tag(book.id)
                }
                .listStyle(.sidebar)
            }

            Divider()

            // Selection controls
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
        .navigationTitle("Books (\(viewModel.filteredBooks.count))")
    }
}
