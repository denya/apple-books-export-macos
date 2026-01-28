import Foundation

struct HTMLExporter {
    static func export(books: [Book]) -> String {
        let totalAnnotations = books.reduce(0) { $0 + $1.annotationCount }

        var html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Apple Books Export</title>
            <style>
                :root {
                    --color-bg: #ffffff;
                    --color-text: #1a1a1a;
                    --color-secondary: #666666;
                    --color-border: #e0e0e0;
                    --color-highlight: #f5f5f5;
                    --color-yellow: #ffd60a;
                    --color-green: #32d74b;
                    --color-blue: #0a84ff;
                    --color-pink: #ff375f;
                    --color-purple: #bf5af2;
                    --color-underline: #8e8e93;
                }

                @media (prefers-color-scheme: dark) {
                    :root {
                        --color-bg: #1a1a1a;
                        --color-text: #f5f5f5;
                        --color-secondary: #aeaeb2;
                        --color-border: #3a3a3c;
                        --color-highlight: #2c2c2e;
                    }
                }

                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }

                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                    background: var(--color-bg);
                    color: var(--color-text);
                    line-height: 1.6;
                    padding: 20px;
                }

                .container {
                    max-width: 900px;
                    margin: 0 auto;
                }

                header {
                    text-align: center;
                    padding: 40px 0;
                    border-bottom: 2px solid var(--color-border);
                    margin-bottom: 40px;
                }

                h1 {
                    font-size: 2.5rem;
                    font-weight: 700;
                    margin-bottom: 10px;
                }

                .subtitle {
                    font-size: 1.1rem;
                    color: var(--color-secondary);
                }

                .search-container {
                    margin-bottom: 30px;
                    position: sticky;
                    top: 20px;
                    background: var(--color-bg);
                    padding: 15px 0;
                    z-index: 100;
                }

                .search-input {
                    width: 100%;
                    padding: 12px 20px;
                    font-size: 1rem;
                    border: 2px solid var(--color-border);
                    border-radius: 8px;
                    background: var(--color-bg);
                    color: var(--color-text);
                }

                .search-input:focus {
                    outline: none;
                    border-color: var(--color-blue);
                }

                .book {
                    margin-bottom: 60px;
                    padding-bottom: 40px;
                    border-bottom: 1px solid var(--color-border);
                }

                .book:last-child {
                    border-bottom: none;
                }

                .book-header {
                    margin-bottom: 30px;
                }

                .book-title {
                    font-size: 2rem;
                    font-weight: 700;
                    margin-bottom: 8px;
                }

                .book-author {
                    font-size: 1.3rem;
                    color: var(--color-secondary);
                    margin-bottom: 8px;
                }

                .book-meta {
                    font-size: 0.9rem;
                    color: var(--color-secondary);
                }

                .annotation {
                    margin-bottom: 30px;
                    padding: 20px;
                    background: var(--color-highlight);
                    border-radius: 8px;
                    border-left: 4px solid var(--color-border);
                }

                .annotation-header {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    margin-bottom: 12px;
                    flex-wrap: wrap;
                }

                .color-indicator {
                    width: 14px;
                    height: 14px;
                    border-radius: 50%;
                }

                .type-badge {
                    font-size: 0.85rem;
                    padding: 4px 10px;
                    background: var(--color-border);
                    border-radius: 4px;
                    text-transform: capitalize;
                }

                .annotation-date {
                    font-size: 0.85rem;
                    color: var(--color-secondary);
                    margin-left: auto;
                }

                .annotation-text {
                    margin-bottom: 12px;
                    line-height: 1.7;
                }

                .annotation-note {
                    font-style: italic;
                    color: var(--color-secondary);
                    padding-left: 16px;
                    border-left: 3px solid var(--color-border);
                }

                .hidden {
                    display: none;
                }

                footer {
                    text-align: center;
                    padding: 40px 0;
                    color: var(--color-secondary);
                    font-size: 0.9rem;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <header>
                    <h1>📚 Apple Books Export</h1>
                    <p class="subtitle">Exported \(totalAnnotations) annotations from \(books.count) books</p>
                    <p class="subtitle">\(ISO8601DateFormatter().string(from: Date()))</p>
                </header>

                <div class="search-container">
                    <input type="text" class="search-input" id="searchInput" placeholder="Search books and annotations...">
                </div>

                <main id="booksContainer">
        """

        // Add each book
        for book in books {
            guard !book.annotations.isEmpty else { continue }

            html += """
                    <div class="book" data-book-id="\(book.assetId)">
                        <div class="book-header">
                            <h2 class="book-title">\(escapeHtml(book.displayTitle))</h2>
                            <p class="book-author">\(escapeHtml(book.displayAuthor))</p>
                            <p class="book-meta">\(book.annotationCount) annotations</p>
                        </div>
            """

            for annotation in book.annotations {
                let colorStyle = getColorStyle(for: annotation.color)

                html += """
                        <div class="annotation">
                            <div class="annotation-header">
                                <div class="color-indicator" style="background-color: \(colorStyle);"></div>
                                <span class="type-badge">\(annotation.type.rawValue)</span>
                """

                if let location = annotation.location {
                    html += """
                                <span class="annotation-date">\(escapeHtml(location))</span>
                    """
                }

                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                html += """
                                <span class="annotation-date">\(dateFormatter.string(from: annotation.createdAt))</span>
                            </div>
                """

                if let text = annotation.text, !text.isEmpty {
                    html += """
                            <div class="annotation-text">\(escapeHtml(text))</div>
                    """
                }

                if let note = annotation.note, !note.isEmpty {
                    html += """
                            <div class="annotation-note">\(escapeHtml(note))</div>
                    """
                }

                html += """
                        </div>
                """
            }

            html += """
                    </div>
            """
        }

        html += """
                </main>

                <footer>
                    <p>Generated by Apple Books Export</p>
                </footer>
            </div>

            <script>
                const searchInput = document.getElementById('searchInput');
                const books = document.querySelectorAll('.book');

                searchInput.addEventListener('input', (e) => {
                    const query = e.target.value.toLowerCase();

                    books.forEach(book => {
                        const text = book.textContent.toLowerCase();
                        if (text.includes(query)) {
                            book.classList.remove('hidden');
                        } else {
                            book.classList.add('hidden');
                        }
                    });
                });
            </script>
        </body>
        </html>
        """

        return html
    }

    private static func escapeHtml(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    private static func getColorStyle(for color: AnnotationColor) -> String {
        switch color {
        case .yellow: return "#ffd60a"
        case .green: return "#32d74b"
        case .blue: return "#0a84ff"
        case .pink: return "#ff375f"
        case .purple: return "#bf5af2"
        case .underline: return "#8e8e93"
        }
    }
}
