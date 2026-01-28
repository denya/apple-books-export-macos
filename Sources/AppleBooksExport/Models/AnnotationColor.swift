import Foundation
import SwiftUI

enum AnnotationColor: String, Codable, CaseIterable {
    case yellow
    case green
    case blue
    case pink
    case purple
    case underline

    var displayColor: Color {
        switch self {
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .underline:
            return .gray
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}
