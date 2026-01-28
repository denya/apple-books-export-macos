import SwiftUI

struct BookRowView: View {
    let book: Book
    @ObservedObject var viewModel: BooksViewModel

    var isSelected: Bool {
        viewModel.selectedBookIds.contains(book.id)
    }

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            // Only show checkbox in selection mode
            if viewModel.isSelectionMode {
                Button(action: { viewModel.toggleBookSelection(book.id) }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select book")
                .accessibilityValue(isSelected ? "selected" : "not selected")
                .accessibilityAddTraits(.isToggle)
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
                    .background(.blue)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .gesture(
                TapGesture(count: 1)
                    .modifiers(.command)
                    .onEnded { _ in
                        if viewModel.isSelectionMode {
                            viewModel.toggleBookSelection(book.id)
                        }
                    }
            )
            .simultaneousGesture(
                TapGesture(count: 1)
                    .modifiers(.shift)
                    .onEnded { _ in
                        if viewModel.isSelectionMode {
                            viewModel.handleShiftClick(book.id)
                        }
                    }
            )
        }
        .padding(.vertical, 2)
        .background(isHovering && viewModel.isSelectionMode ? Color(nsColor: .quaternaryLabelColor).opacity(0.2) : .clear)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
