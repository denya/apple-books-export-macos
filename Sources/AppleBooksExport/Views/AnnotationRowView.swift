import SwiftUI

struct AnnotationRowView: View {
    let annotation: Annotation
    @ObservedObject var viewModel: BooksViewModel

    var isSelected: Bool {
        viewModel.selectedAnnotationIds.contains(annotation.id)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Only show checkbox in selection mode
            if viewModel.isSelectionMode {
                Button(action: { viewModel.toggleAnnotationSelection(annotation.id) }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select annotation")
                .accessibilityValue(isSelected ? "selected" : "not selected")
                .accessibilityAddTraits(.isToggle)
            }

            VStack(alignment: .leading, spacing: 8) {
                // Header with color, type, and location
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(annotation.color.displayColor)
                            .frame(width: 10, height: 10)
                            .accessibilityHidden(true)

                        Text(annotation.color.displayName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Highlight color: \(annotation.color.displayName)")

                    Text(annotation.type.rawValue.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)

                    if let location = annotation.location, !location.isEmpty {
                        Text(location)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(annotation.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Text content
                if let text = annotation.text, !text.isEmpty {
                    Text(text)
                        .lineLimit(3)
                }

                // Note content
                if let note = annotation.note, !note.isEmpty {
                    Text(note)
                        .italic()
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .background(.quaternary)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.separator, lineWidth: 0.5)
        )
    }
}
