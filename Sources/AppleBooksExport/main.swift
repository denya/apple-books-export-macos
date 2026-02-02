import SwiftUI

@main
struct AppleBooksExportApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("annotationTextSizeDelta") private var annotationTextSizeDelta: Double = 0

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(after: .textFormatting) {
                Button("Increase Text Size") {
                    annotationTextSizeDelta = AnnotationTextSizeSettings.clampDelta(
                        annotationTextSizeDelta + AnnotationTextSizeSettings.step
                    )
                }
                .keyboardShortcut("=", modifiers: .command)

                Button("Decrease Text Size") {
                    annotationTextSizeDelta = AnnotationTextSizeSettings.clampDelta(
                        annotationTextSizeDelta - AnnotationTextSizeSettings.step
                    )
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("Reset Text Size") {
                    annotationTextSizeDelta = AnnotationTextSizeSettings.clampDelta(0)
                }
                .keyboardShortcut("0", modifiers: .command)
            }
        }
    }
}
