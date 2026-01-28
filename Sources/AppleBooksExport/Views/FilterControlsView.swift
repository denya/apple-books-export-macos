import SwiftUI

struct FilterControlsView: View {
    @ObservedObject var viewModel: BooksViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Type filters
            HStack(spacing: 12) {
                Toggle(isOn: $viewModel.showHighlights) {
                    Label("Highlights", systemImage: "highlighter")
                        .font(.caption)
                }
                .toggleStyle(.checkbox)

                Toggle(isOn: $viewModel.showBookmarks) {
                    Label("Bookmarks", systemImage: "bookmark")
                        .font(.caption)
                }
                .toggleStyle(.checkbox)

                Toggle(isOn: $viewModel.showNotes) {
                    Label("Notes", systemImage: "note.text")
                        .font(.caption)
                }
                .toggleStyle(.checkbox)
            }

            // Color filters
            HStack(spacing: 8) {
                Text("Colors:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(AnnotationColor.allCases, id: \.self) { color in
                    ColorFilterButton(
                        color: color,
                        isSelected: viewModel.selectedColors.contains(color)
                    ) {
                        if viewModel.selectedColors.contains(color) {
                            viewModel.selectedColors.remove(color)
                        } else {
                            viewModel.selectedColors.insert(color)
                        }
                    }
                }

                if !viewModel.selectedColors.isEmpty {
                    Button("Clear") {
                        viewModel.selectedColors.removeAll()
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                    .accessibilityLabel("Clear all color filters")
                }
            }
        }
    }
}

struct ColorFilterButton: View {
    let color: AnnotationColor
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color.displayColor)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .strokeBorder(Color.primary, lineWidth: isSelected ? 2 : 0)
                )
                .scaleEffect(isHovering ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isHovering)
        }
        .buttonStyle(.plain)
        .frame(minWidth: 20, minHeight: 20)
        .accessibilityLabel("Filter by \(color.displayName)")
        .accessibilityValue(isSelected ? "selected" : "not selected")
        .accessibilityAddTraits(.isButton)
        .help(color.displayName)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
