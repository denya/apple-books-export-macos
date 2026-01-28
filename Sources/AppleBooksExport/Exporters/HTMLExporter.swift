import Foundation

struct HTMLExporter {
    static func export(books: [Book]) -> String {
        let totalHighlights = books.reduce(0) { $0 + $1.annotationCount }
        let totalBooks = books.count

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let exportDate = dateFormatter.string(from: Date())

        var html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Apple Books Highlights</title>
          <link rel="preconnect" href="https://fonts.googleapis.com">
          <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
          <link href="https://fonts.googleapis.com/css2?family=Crimson+Text:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
          <style>
            * {
              box-sizing: border-box;
              margin: 0;
              padding: 0;
            }

            :root {
              --bg-page: #faf8f5;
              --bg-card: #ffffff;
              --bg-sidebar: #f5f3f0;
              --bg-hover: #f0ede8;
              --text-primary: #2c2c2c;
              --text-secondary: #6b6b6b;
              --text-tertiary: #999999;
              --accent-primary: #d4a574;
              --border-color: #e8e5e0;
              --dot-yellow: #ffc107;
              --dot-green: #4caf50;
              --dot-blue: #2196f3;
              --dot-pink: #e91e63;
              --dot-purple: #9c27b0;
              --dot-underline: #757575;
            }

            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
              font-size: 1.0625rem;
              line-height: 1.7;
              color: var(--text-primary);
              background: var(--bg-page);
              margin: 0;
              padding: 0;
            }

            .header {
              position: sticky;
              top: 0;
              background: var(--bg-card);
              border-bottom: 1px solid var(--border-color);
              padding: 1.5rem 2rem;
              z-index: 100;
              box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            }

            .header-content {
              display: flex;
              justify-content: space-between;
              align-items: center;
              margin-bottom: 1rem;
            }

            .header h1 {
              font-family: 'Crimson Text', Georgia, serif;
              font-size: 2.5rem;
              font-weight: 600;
              color: var(--text-primary);
              letter-spacing: -0.02em;
            }

            .header-actions {
              display: flex;
              gap: 0.75rem;
              align-items: center;
            }

            .expand-all-btn {
              padding: 0.5rem 1rem;
              font-size: 0.9375rem;
              font-family: inherit;
              background: transparent;
              border: 1px solid var(--border-color);
              border-radius: 6px;
              color: var(--text-secondary);
              cursor: pointer;
              transition: all 0.2s ease;
            }

            .expand-all-btn:hover {
              background: var(--bg-hover);
              border-color: var(--accent-primary);
              color: var(--text-primary);
            }

            .search-container {
              margin-bottom: 1rem;
            }

            .search-box {
              width: 100%;
              padding: 0.75rem 1rem;
              font-size: 1rem;
              font-family: inherit;
              border: 1px solid var(--border-color);
              border-radius: 8px;
              background: var(--bg-page);
              color: var(--text-primary);
              transition: all 0.2s ease;
            }

            .search-box:focus {
              outline: none;
              border-color: var(--accent-primary);
              box-shadow: 0 0 0 3px rgba(212, 165, 116, 0.1);
            }

            .stats {
              color: var(--text-tertiary);
              font-size: 0.9375rem;
            }

            .container {
              display: flex;
              min-height: calc(100vh - 180px);
            }

            .sidebar {
              width: 280px;
              background: var(--bg-sidebar);
              border-right: 1px solid var(--border-color);
              padding: 2rem 1.5rem;
              overflow-y: auto;
              position: sticky;
              top: 180px;
              height: calc(100vh - 180px);
              flex-shrink: 0;
            }

            .sidebar h3 {
              font-family: 'Crimson Text', Georgia, serif;
              font-size: 1.125rem;
              font-weight: 600;
              margin-bottom: 1rem;
              color: var(--text-primary);
            }

            .book-list {
              list-style: none;
            }

            .book-list li {
              margin-bottom: 0.5rem;
            }

            .book-link {
              display: flex;
              justify-content: space-between;
              align-items: baseline;
              padding: 0.5rem 0.75rem;
              text-decoration: none;
              color: var(--text-secondary);
              border-radius: 6px;
              transition: all 0.2s ease;
              font-size: 0.9375rem;
            }

            .book-link:hover {
              background: var(--bg-hover);
              color: var(--accent-primary);
            }

            .book-link.active {
              background: var(--bg-card);
              color: var(--text-primary);
              border-left: 3px solid var(--accent-primary);
            }

            .book-title {
              flex: 1;
              overflow: hidden;
              text-overflow: ellipsis;
              white-space: nowrap;
              margin-right: 0.5rem;
            }

            .book-count {
              font-size: 0.875rem;
              color: var(--text-tertiary);
            }

            main {
              flex: 1;
              padding: 3rem 2rem;
              max-width: 900px;
              margin: 0 auto;
            }

            .book {
              background: var(--bg-card);
              border-radius: 12px;
              padding: 2rem;
              margin-bottom: 2rem;
              box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
              transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
              scroll-margin-top: 200px;
            }

            .book:hover {
              box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            }

            .book-header {
              display: flex;
              justify-content: space-between;
              align-items: flex-start;
              margin-bottom: 1.5rem;
              cursor: pointer;
              user-select: none;
            }

            .book-info {
              flex: 1;
            }

            .book h2 {
              font-family: 'Crimson Text', Georgia, serif;
              font-size: 1.75rem;
              font-weight: 600;
              color: var(--text-primary);
              margin-bottom: 0.5rem;
              line-height: 1.3;
            }

            .author {
              color: var(--text-secondary);
              font-size: 1rem;
            }

            .collapse-btn {
              background: transparent;
              border: none;
              cursor: pointer;
              padding: 0.5rem;
              color: var(--text-secondary);
              transition: all 0.2s ease;
              border-radius: 6px;
            }

            .collapse-btn:hover {
              background: var(--bg-hover);
              color: var(--text-primary);
            }

            .chevron {
              transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            }

            .book.collapsed .chevron {
              transform: rotate(-90deg);
            }

            .highlights {
              overflow: hidden;
              transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            }

            .book.collapsed .highlights {
              max-height: 0 !important;
              margin-bottom: 0;
            }

            .highlight {
              display: flex;
              gap: 12px;
              margin-bottom: 1.5rem;
              padding-bottom: 1.5rem;
              border-bottom: 1px solid var(--border-color);
            }

            .highlight:last-child {
              border-bottom: none;
              padding-bottom: 0;
              margin-bottom: 0;
            }

            .color-dot {
              width: 8px;
              height: 8px;
              border-radius: 50%;
              flex-shrink: 0;
              margin-top: 6px;
            }

            .color-dot.yellow {
              background: var(--dot-yellow);
              box-shadow: 0 0 8px rgba(255, 193, 7, 0.3);
            }

            .color-dot.green {
              background: var(--dot-green);
              box-shadow: 0 0 8px rgba(76, 175, 80, 0.3);
            }

            .color-dot.blue {
              background: var(--dot-blue);
              box-shadow: 0 0 8px rgba(33, 150, 243, 0.3);
            }

            .color-dot.pink {
              background: var(--dot-pink);
              box-shadow: 0 0 8px rgba(233, 30, 99, 0.3);
            }

            .color-dot.purple {
              background: var(--dot-purple);
              box-shadow: 0 0 8px rgba(156, 39, 176, 0.3);
            }

            .color-dot.underline {
              background: var(--dot-underline);
              box-shadow: 0 0 8px rgba(117, 117, 117, 0.3);
            }

            .highlight-content {
              flex: 1;
            }

            .highlight-text {
              font-size: 1.0625rem;
              line-height: 1.7;
              color: var(--text-primary);
              margin-bottom: 0.5rem;
            }

            .note {
              font-style: italic;
              color: var(--text-secondary);
              margin-top: 0.75rem;
              font-size: 1rem;
            }

            .highlight-meta {
              display: flex;
              justify-content: space-between;
              align-items: center;
              margin-top: 0.75rem;
              gap: 1rem;
            }

            .location {
              font-size: 0.875rem;
              color: var(--text-tertiary);
            }

            time {
              font-size: 0.875rem;
              color: var(--text-tertiary);
              text-align: right;
            }

            .hidden {
              display: none;
            }
          </style>
        </head>
        <body>
          <header class="header">
            <div class="header-content">
              <h1>Apple Books Highlights</h1>
              <div class="header-actions">
                <button class="expand-all-btn">Collapse All</button>
              </div>
            </div>
            <div class="search-container">
              <input type="search" class="search-box" placeholder="Search books or highlights..." aria-label="Search" />
            </div>
            <div class="stats">\(totalHighlights) highlights from \(totalBooks) books • Exported \(exportDate)</div>
          </header>

          <div class="container">
            <aside class="sidebar">
              <h3>Library</h3>
              <ul class="book-list">
        """

        // Sidebar book list
        for book in books {
            let bookId = "book-\(book.assetId)"
            html += """
                        <li>
                          <a href="#\(bookId)" class="book-link">
                            <span class="book-title">\(escapeHtml(book.displayTitle))</span>
                            <span class="book-count">\(book.annotationCount)</span>
                          </a>
                        </li>
            """
        }

        html += """
                      </ul>
                    </aside>

                    <main>
        """

        // Books
        for book in books {
            let bookId = "book-\(book.assetId)"
            html += """
                      <section id="\(bookId)" class="book">
                        <div class="book-header">
                          <div class="book-info">
                            <h2>\(escapeHtml(book.displayTitle))</h2>
                            <p class="author">by \(escapeHtml(book.displayAuthor))</p>
                          </div>
                          <button class="collapse-btn" aria-label="Toggle highlights">
                            <svg class="chevron" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                              <polyline points="6 9 12 15 18 9"></polyline>
                            </svg>
                          </button>
                        </div>
                        <div class="highlights">
            """

            // Highlights
            for annotation in book.annotations {
                let colorClass = getColorClass(for: annotation.color)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long

                html += """
                          <div class="highlight">
                            <span class="color-dot \(colorClass)"></span>
                            <div class="highlight-content">
                """

                if let text = annotation.text, !text.isEmpty {
                    html += """
                              <p class="highlight-text">\(escapeHtml(text))</p>
                    """
                }

                if let note = annotation.note, !note.isEmpty {
                    html += """
                              <p class="note">\(escapeHtml(note))</p>
                    """
                }

                html += """
                              <div class="highlight-meta">
                """

                if let location = annotation.location, !location.isEmpty {
                    html += """
                                <span class="location">\(escapeHtml(location))</span>
                    """
                }

                html += """
                                <time>\(dateFormatter.string(from: annotation.createdAt))</time>
                              </div>
                            </div>
                          </div>
                """
            }

            html += """
                        </div>
                      </section>

            """
        }

        html += """
                    </main>
                  </div>

                  <script>
                    document.addEventListener('DOMContentLoaded', () => {
                      document.querySelectorAll('.highlights').forEach(highlights => {
                        highlights.style.maxHeight = highlights.scrollHeight + 'px';
                      });
                    });

                    const searchInput = document.querySelector('.search-box');
                    let searchTimeout;

                    searchInput.addEventListener('input', (e) => {
                      clearTimeout(searchTimeout);
                      searchTimeout = setTimeout(() => {
                        const query = e.target.value.toLowerCase().trim();
                        const books = document.querySelectorAll('.book');

                        if (query === '') {
                          books.forEach(book => book.classList.remove('hidden'));
                        } else {
                          books.forEach(book => {
                            const text = book.textContent.toLowerCase();
                            if (text.includes(query)) {
                              book.classList.remove('hidden');
                            } else {
                              book.classList.add('hidden');
                            }
                          });
                        }
                      }, 150);
                    });

                    document.querySelectorAll('.book-header').forEach(header => {
                      header.addEventListener('click', () => {
                        const book = header.closest('.book');
                        book.classList.toggle('collapsed');
                      });
                    });

                    const expandAllBtn = document.querySelector('.expand-all-btn');
                    let allCollapsed = false;

                    expandAllBtn.addEventListener('click', () => {
                      const books = document.querySelectorAll('.book');
                      allCollapsed = !allCollapsed;

                      books.forEach(book => {
                        if (allCollapsed) {
                          book.classList.add('collapsed');
                        } else {
                          book.classList.remove('collapsed');
                        }
                      });

                      expandAllBtn.textContent = allCollapsed ? 'Expand All' : 'Collapse All';
                    });

                    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                      anchor.addEventListener('click', function (e) {
                        e.preventDefault();
                        const target = document.querySelector(this.getAttribute('href'));
                        if (target) {
                          document.querySelectorAll('.book-link').forEach(link => {
                            link.classList.remove('active');
                          });
                          this.classList.add('active');
                          target.classList.remove('collapsed');
                          target.scrollIntoView({ behavior: 'smooth', block: 'start' });
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

    private static func getColorClass(for color: AnnotationColor) -> String {
        switch color {
        case .yellow: return "yellow"
        case .green: return "green"
        case .blue: return "blue"
        case .pink: return "pink"
        case .purple: return "purple"
        case .underline: return "underline"
        }
    }
}
