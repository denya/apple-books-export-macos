import SwiftUI

struct AllAnnotationsView: View {
    @ObservedObject var viewModel: BooksViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("All Annotations")
                    .font(.title)
                    .fontWeight(.bold)

                HStack(spacing: 16) {
                    Label("\(viewModel.filteredBooks.count) books", systemImage: "book")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Label("\(viewModel.totalAnnotationCount) annotations", systemImage: "highlighter")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // All annotations from all books
            if viewModel.filteredBooks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.badge.xmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No annotations")
                        .font(.headline)
                    Text("Adjust your filters or search")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.filteredBooks) { book in
                        Section {
                            ForEach(book.annotations) { annotation in
                                AnnotationRowView(
                                    annotation: annotation,
                                    viewModel: viewModel
                                )
                            }
                        } header: {
                            HStack(spacing: 8) {
                                Button(action: {
                                    viewModel.toggleBookSelection(book.id)
                                }) {
                                    Image(systemName: viewModel.selectedBookIds.contains(book.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(viewModel.selectedBookIds.contains(book.id) ? .blue : .secondary)
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(book.displayTitle)
                                        .font(.headline)
                                    Text(book.displayAuthor)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
    }
}
