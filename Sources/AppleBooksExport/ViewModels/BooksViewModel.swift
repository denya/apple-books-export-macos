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

    // Filters
    @Published var showHighlights: Bool = true
    @Published var showBookmarks: Bool = false
    @Published var showNotes: Bool = true
    @Published var selectedColors: Set<AnnotationColor> = []

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

        return result
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

            // Select all books by default
            self.selectedBookIds = Set(loadedBooks.map { $0.id })
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleBookSelection(_ id: String) {
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
