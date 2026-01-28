import SwiftUI

struct BookRowView: View {
    let book: Book
    @ObservedObject var viewModel: BooksViewModel

    var isSelected: Bool {
        viewModel.selectedBookIds.contains(book.id)
    }

    var body: some View {
        HStack(spacing: 8) {
            Button(action: { viewModel.toggleBookSelection(book.id) }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .secondary)
            }
            .buttonStyle(.plain)

            HStack(spacing: 0) {
                Text(book.displayTitle)
                    .font(.body)
                    .lineLimit(1)

                Text(" - ")
                    .foregroundStyle(.secondary)

                Text(book.displayAuthor)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(" - ")
                    .foregroundStyle(.secondary)

                Text("\(book.annotationCount) quotes")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
}
