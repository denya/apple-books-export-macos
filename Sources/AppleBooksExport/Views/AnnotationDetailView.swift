import SwiftUI

struct AnnotationDetailView: View {
    let book: Book
    @ObservedObject var viewModel: BooksViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Book header
            VStack(alignment: .leading, spacing: 8) {
                Text(book.displayTitle)
                    .font(.title)
                    .fontWeight(.bold)

                Text(book.displayAuthor)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    if let genre = book.genre {
                        Label(genre, systemImage: "tag")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Label("\(book.annotationCount) annotations", systemImage: "number")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Annotations list
            if book.annotations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.badge.xmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No annotations")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(book.annotations) { annotation in
                        AnnotationRowView(
                            annotation: annotation,
                            viewModel: viewModel
                        )
                    }
                }
                .listStyle(.inset)
            }

            Divider()

            // Annotation selection controls
            HStack {
                Text("\(selectedAnnotationCount) / \(book.annotationCount) selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Select All") {
                    viewModel.selectAllAnnotations(for: book.id)
                }
                .buttonStyle(.link)
                .font(.caption)
                Button("Deselect All") {
                    viewModel.deselectAllAnnotations(for: book.id)
                }
                .buttonStyle(.link)
                .font(.caption)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
        }
    }

    private var selectedAnnotationCount: Int {
        book.annotations.filter { viewModel.selectedAnnotationIds.contains($0.id) }.count
    }
}
