import AppKit

enum AnnotationTextSizeSettings {
    static let minSize: Double = 11
    static let maxSize: Double = 22
    static let step: Double = 1

    static var baseSize: Double {
        Double(NSFont.systemFontSize)
    }

    static var minDelta: Double {
        minSize - baseSize
    }

    static var maxDelta: Double {
        maxSize - baseSize
    }

    static func clampDelta(_ delta: Double) -> Double {
        min(max(delta, minDelta), maxDelta)
    }

    static func size(fromDelta delta: Double) -> CGFloat {
        CGFloat(baseSize + clampDelta(delta))
    }
}
