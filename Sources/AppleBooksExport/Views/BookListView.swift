import SwiftUI

struct BookListView: View {
    @ObservedObject var viewModel: BooksViewModel
    @Binding var selectedBookIds: Set<String>
    let onExportBook: (Book) -> Void

    @ViewBuilder
    private var sortAndFilterToolbar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Menu {
                    ForEach(BookSortOption.allCases) { option in
                        Button(action: { viewModel.bookSort = option }) {
                            HStack {
                                Text(option.rawValue)
                                if viewModel.bookSort == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .font(.caption)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .accessibilityLabel("Sort books")
                .accessibilityHint("Current sort: \(viewModel.bookSort.rawValue)")

                Button(action: { viewModel.showFilters.toggle() }) {
                    Label("Filters", systemImage: viewModel.showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)

            if viewModel.showFilters {
                FilterControlsView(viewModel: viewModel)
                    .padding(8)
                    .background(.thinMaterial)
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField("Search books", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .accessibilityLabel("Search books")
                .keyboardShortcut("f", modifiers: .command)
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Error")
                .font(.headline)
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button("Try Again") {
                Task {
                    await viewModel.loadBooks()
                }
            }
        }
        .padding(24)
        .background(.red.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.red.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var emptyView: some View {
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
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            Divider()
            sortAndFilterToolbar
            Divider()

            // Books list
            if viewModel.isLoading {
                ProgressView("Loading books...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.errorMessage != nil {
                errorView
            } else if viewModel.filteredBooks.isEmpty {
                emptyView
            } else {
                List(selection: $selectedBookIds) {
                    // "All books" item
                    Button(action: {
                        selectedBookIds.removeAll()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "book.fill")
                                .foregroundStyle(selectedBookIds.isEmpty ? .blue : .secondary)
                            Text("All Books")
                                .font(.body)
                                .fontWeight(selectedBookIds.isEmpty ? .semibold : .regular)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        selectedBookIds.isEmpty ? Color.blue.opacity(0.15) : Color.clear
                    )
                    .padding(.vertical, 2)

                    Divider()

                    // Individual books
                    ForEach(viewModel.filteredBooks) { book in
                        BookRowView(
                            book: book,
                            viewModel: viewModel,
                            onExport: onExportBook
                        )
                            .tag(book.id)
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
                    .keyboardShortcut("a", modifiers: .command)
                    .accessibilityHint("Keyboard shortcut: Command+A")
                    Button("Deselect All") {
                        viewModel.deselectAll()
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
                .padding(8)
                .background(.ultraThinMaterial)
            }
        }
        .navigationTitle("Books (\(viewModel.filteredBooks.count))")
    }
}
