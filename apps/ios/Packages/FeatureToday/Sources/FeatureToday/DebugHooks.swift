import SwiftUI

extension View {
    /// DEBUG-only deep link: when the `COPE_OPEN` env equals `value`, runs
    /// `action` shortly after the view appears so a full-screen cover can be
    /// opened (and screenshotted) with real injected data in the Simulator.
    @ViewBuilder
    func debugAutoOpen(_ value: String, perform action: @escaping () -> Void) -> some View {
        #if DEBUG
        onAppear {
            guard ProcessInfo.processInfo.environment["COPE_OPEN"] == value else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: action)
        }
        #else
        self
        #endif
    }
}
