import SwiftUI

struct BookRowView: View {
    let book: Book
    @ObservedObject var viewModel: BooksViewModel

    var isSelected: Bool {
        viewModel.selectedBookIds.contains(book.id)
    }

    var body: some View {
        HStack(spacing: 8) {
            // Only show checkbox in selection mode
            if viewModel.isSelectionMode {
                Button(action: { viewModel.toggleBookSelection(book.id) }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 6) {
                Text(book.displayTitle)
                    .font(.body)
                    .lineLimit(1)

                Text("-")
                    .foregroundStyle(.secondary)

                Text(book.displayAuthor)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                // Small badge for quote count
                Text("\(book.annotationCount)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
}
