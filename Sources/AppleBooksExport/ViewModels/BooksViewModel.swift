import Foundation
import SwiftUI

@MainActor
class BooksViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var selectedBookIds: Set<String> = []
    @Published var selectedAnnotationIds: Set<Int> = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSelectionMode: Bool = false
    @Published var showFilters: Bool = false

    // Filters
    @Published var showHighlights: Bool = true
    @Published var showBookmarks: Bool = false
    @Published var showNotes: Bool = true
    @Published var selectedColors: Set<AnnotationColor> = []

    // Sorting
    @Published var bookSort: BookSortOption = .title
    @Published var highlightSort: HighlightSortOption = .book

    private var database: AppleBooksDatabase?

    var filteredBooks: [Book] {
        var result = books

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { book in
                book.displayTitle.localizedCaseInsensitiveContains(searchText) ||
                book.displayAuthor.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filter annotations within each book
        result = result.compactMap { book in
            let filteredAnnotations = book.annotations.filter { annotation in
                // Filter by type
                if annotation.type == .highlight && !showHighlights { return false }
                if annotation.type == .bookmark && !showBookmarks { return false }
                if annotation.type == .note && !showNotes { return false }

                // Filter by color
                if !selectedColors.isEmpty && !selectedColors.contains(annotation.color) {
                    return false
                }

                return true
            }

            guard !filteredAnnotations.isEmpty else { return nil }

            var filteredBook = book
            filteredBook.annotations = filteredAnnotations
            return filteredBook
        }

        // Sort books
        result = sortBooks(result)

        return result
    }

    private func sortBooks(_ books: [Book]) -> [Book] {
        switch bookSort {
        case .title:
            return books.sorted { ($0.title ?? "") < ($1.title ?? "") }
        case .author:
            return books.sorted { ($0.author ?? "") < ($1.author ?? "") }
        case .lastHighlightAsc:
            return books.sorted { book0, book1 in
                let date0 = book0.annotations.map { $0.createdAt }.max() ?? Date.distantPast
                let date1 = book1.annotations.map { $0.createdAt }.max() ?? Date.distantPast
                return date0 < date1
            }
        case .lastHighlightDesc:
            return books.sorted { book0, book1 in
                let date0 = book0.annotations.map { $0.createdAt }.max() ?? Date.distantPast
                let date1 = book1.annotations.map { $0.createdAt }.max() ?? Date.distantPast
                return date0 > date1
            }
        }
    }

    func sortedHighlights(for books: [Book]) -> [(book: Book, annotation: Annotation)] {
        var highlights: [(book: Book, annotation: Annotation)] = []

        for book in books {
            for annotation in book.annotations {
                highlights.append((book: book, annotation: annotation))
            }
        }

        switch highlightSort {
        case .book:
            // Already sorted by book
            return highlights
        case .dateAsc:
            return highlights.sorted { $0.annotation.createdAt < $1.annotation.createdAt }
        case .dateDesc:
            return highlights.sorted { $0.annotation.createdAt > $1.annotation.createdAt }
        }
    }

    var selectedBooks: [Book] {
        books.filter { selectedBookIds.contains($0.id) }
    }

    var selectedBooksWithFilteredAnnotations: [Book] {
        selectedBooks.map { book in
            var filteredBook = book
            // Only include selected annotations
            if !selectedAnnotationIds.isEmpty {
                filteredBook.annotations = book.annotations.filter { selectedAnnotationIds.contains($0.id) }
            }
            return filteredBook
        }
    }

    var totalAnnotationCount: Int {
        filteredBooks.reduce(0) { $0 + $1.annotationCount }
    }

    var selectedAnnotationCount: Int {
        selectedAnnotationIds.isEmpty
            ? selectedBooks.reduce(0) { $0 + $1.annotationCount }
            : selectedAnnotationIds.count
    }

    func loadBooks() async {
        isLoading = true
        errorMessage = nil

        do {
            // Find databases
            let db = try AppleBooksDatabase.findDatabases()
            self.database = db

            // Load books on background thread
            let loadedBooks = try await Task.detached {
                try db.loadBooks()
            }.value

            self.books = loadedBooks

            // In selection mode, select all books by default
            if self.isSelectionMode {
                self.selectedBookIds = Set(loadedBooks.map { $0.id })
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleBookSelection(_ id: String) {
        guard isSelectionMode else { return }
        if selectedBookIds.contains(id) {
            selectedBookIds.remove(id)
            // Also deselect annotations from this book
            if let book = books.first(where: { $0.id == id }) {
                for annotation in book.annotations {
                    selectedAnnotationIds.remove(annotation.id)
                }
            }
        } else {
            selectedBookIds.insert(id)
        }
    }

    func toggleSelectionMode() {
        isSelectionMode.toggle()
        if isSelectionMode {
            // When entering selection mode, select all by default
            selectedBookIds = Set(books.map { $0.id })
        } else {
            // Clear selection when exiting
            selectedBookIds.removeAll()
            selectedAnnotationIds.removeAll()
        }
    }

    func getBooksForView(selectedBookId: String?) -> [Book] {
        guard let selectedBookId = selectedBookId else {
            // "All books" selected - return all filtered books
            return filteredBooks
        }

        // Single book selected
        if let book = filteredBooks.first(where: { $0.id == selectedBookId }) {
            return [book]
        }

        return []
    }

    func toggleAnnotationSelection(_ id: Int) {
        if selectedAnnotationIds.contains(id) {
            selectedAnnotationIds.remove(id)
        } else {
            selectedAnnotationIds.insert(id)
        }
    }

    func selectAll() {
        selectedBookIds = Set(filteredBooks.map { $0.id })
        selectedAnnotationIds.removeAll()
    }

    func deselectAll() {
        selectedBookIds.removeAll()
        selectedAnnotationIds.removeAll()
    }

    func selectAllAnnotations(for bookId: String) {
        guard let book = books.first(where: { $0.id == bookId }) else { return }
        for annotation in book.annotations {
            selectedAnnotationIds.insert(annotation.id)
        }
    }

    func deselectAllAnnotations(for bookId: String) {
        guard let book = books.first(where: { $0.id == bookId }) else { return }
        for annotation in book.annotations {
            selectedAnnotationIds.remove(annotation.id)
        }
    }
}
