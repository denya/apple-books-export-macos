import SwiftUI

struct AllAnnotationsView: View {
    @ObservedObject var viewModel: BooksViewModel
    let books: [Book]
    let title: String?
    @Binding var annotationTextSizeDelta: Double

    private var clampedTextSizeDelta: Double {
        AnnotationTextSizeSettings.clampDelta(annotationTextSizeDelta)
    }

    private var currentTextSize: CGFloat {
        AnnotationTextSizeSettings.size(fromDelta: annotationTextSizeDelta)
    }

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

                    Spacer()

                    HStack(spacing: 6) {
                        Text("Text Size")
                            .foregroundStyle(.secondary)
                        Button(action: { decrementTextSize() }) {
                            Image(systemName: "textformat.size.smaller")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .accessibilityLabel("Decrease text size")
                        .help("Decrease text size")
                        .disabled(clampedTextSizeDelta <= AnnotationTextSizeSettings.minDelta)

                        Text("\(Int(currentTextSize.rounded())) pt")
                            .monospacedDigit()

                        Button(action: { incrementTextSize() }) {
                            Image(systemName: "textformat.size.larger")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .accessibilityLabel("Increase text size")
                        .help("Increase text size")
                        .disabled(clampedTextSizeDelta >= AnnotationTextSizeSettings.maxDelta)
                    }
                    .font(.body)
                    .fixedSize()

                    // Sort menu for highlights
                    if books.count > 0 {
                        Menu {
                            ForEach(HighlightSortOption.allCases) { option in
                                Button(action: { viewModel.highlightSort = option }) {
                                    HStack {
                                        Text(option.rawValue)
                                        if viewModel.highlightSort == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .fixedSize()
                        .accessibilityLabel("Sort highlights")
                        .accessibilityHint("Current sort: \(viewModel.highlightSort.rawValue)")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .cornerRadius(8)
            .padding(.horizontal)

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
                .padding(24)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if viewModel.highlightSort == .book {
                        // Group by book
                        ForEach(books) { book in
                            Section {
                                ForEach(book.annotations) { annotation in
                                    AnnotationRowView(
                                        annotation: annotation,
                                        viewModel: viewModel,
                                        annotationTextFontSize: currentTextSize
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
                                    .padding(.horizontal, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(6)
                                }
                            }
                        }
                    } else {
                        // Sort by date
                        let sortedHighlights = viewModel.sortedHighlights(for: books)
                        ForEach(Array(sortedHighlights.enumerated()), id: \.offset) { _, item in
                            VStack(spacing: 4) {
                                if books.count > 1 {
                                    HStack {
                                        Text(item.book.displayTitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("•")
                                            .foregroundStyle(.tertiary)
                                        Text(item.book.displayAuthor)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                AnnotationRowView(
                                    annotation: item.annotation,
                                    viewModel: viewModel,
                                    annotationTextFontSize: currentTextSize
                                )
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .onAppear {
            annotationTextSizeDelta = clampedTextSizeDelta
        }
    }

    private func decrementTextSize() {
        annotationTextSizeDelta = AnnotationTextSizeSettings.clampDelta(
            clampedTextSizeDelta - AnnotationTextSizeSettings.step
        )
    }

    private func incrementTextSize() {
        annotationTextSizeDelta = AnnotationTextSizeSettings.clampDelta(
            clampedTextSizeDelta + AnnotationTextSizeSettings.step
        )
    }
}
