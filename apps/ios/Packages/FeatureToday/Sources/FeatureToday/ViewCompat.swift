import SwiftUI

extension View {
    /// Presents `content` as a full-screen cover on iOS. On macOS (used only for
    /// `swift build` verification) `fullScreenCover` is unavailable, so falls
    /// back to a sheet.
    @ViewBuilder
    func copeFullCover<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(iOS)
        fullScreenCover(isPresented: isPresented, content: content)
        #else
        sheet(isPresented: isPresented, content: content)
        #endif
    }
}
