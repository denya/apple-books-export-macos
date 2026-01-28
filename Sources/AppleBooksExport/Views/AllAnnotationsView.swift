import SwiftUI

struct AllAnnotationsView: View {
    @ObservedObject var viewModel: BooksViewModel
    let books: [Book]
    let title: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(title ?? (books.count == 1 ? books[0].displayTitle : "Highlights"))
                    .font(.title)
                    .fontWeight(.bold)

                if let singleBook = books.count == 1 ? books.first : nil {
                    Text(singleBook.displayAuthor)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    if books.count > 1 {
                        Label("\(books.count) books", systemImage: "book")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    let totalHighlights = books.reduce(0) { $0 + $1.annotationCount }
                    Label("\(totalHighlights) highlights", systemImage: "highlighter")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // All annotations from selected books
            if books.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.badge.xmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No highlights")
                        .font(.headline)
                    Text("Adjust your filters or search")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(books) { book in
                        Section {
                            ForEach(book.annotations) { annotation in
                                AnnotationRowView(
                                    annotation: annotation,
                                    viewModel: viewModel
                                )
                            }
                        } header: {
                            // Only show book header if viewing multiple books
                            if books.count > 1 {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(book.displayTitle)
                                        .font(.headline)
                                    Text(book.displayAuthor)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
    }
}
