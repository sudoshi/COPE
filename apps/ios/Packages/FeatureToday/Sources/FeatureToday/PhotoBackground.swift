import SwiftUI
import DesignSystem

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A gentle full-screen, soothing photo backdrop that softly crossfades between
/// calm nature scenes every 2 seconds. Blurred + warm-scrimmed so foreground
/// content stays legible and the whole thing feels dreamy rather than busy.
/// Honors Reduce Motion (holds a single still).
struct PhotoBackground: View {
    var names: [String] = ["bg-110", "bg-1018", "bg-1039", "bg-1043", "bg-1015"]
    let reduceMotion: Bool

    @State private var index = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            CopeColor.canvas
            ForEach(names.indices, id: \.self) { i in
                bundledImage(names[i])
                    .resizable()
                    .scaledToFill()
                    .opacity(i == index ? 1 : 0)
            }
        }
        .blur(radius: 0)
        .overlay(scrim)
        .clipped()
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.2), value: index)
        .onReceive(timer) { _ in
            guard !reduceMotion, names.count > 1 else { return }
            index = (index + 1) % names.count
        }
    }

    /// Warm veil — lighter over the orb (upper area), heavier behind the copy
    /// and buttons (lower area) — so dark ink text stays readable.
    private var scrim: some View {
        LinearGradient(
            stops: [
                .init(color: CopeColor.canvas.opacity(0.48), location: 0.0),
                .init(color: CopeColor.canvas.opacity(0.36), location: 0.28),
                .init(color: CopeColor.canvas.opacity(0.70), location: 0.60),
                .init(color: CopeColor.canvas.opacity(0.92), location: 1.0)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    private func bundledImage(_ name: String) -> Image {
        guard let url = Bundle.module.url(forResource: name, withExtension: "jpg", subdirectory: "Backgrounds") else {
            return Image(systemName: "photo")
        }
        #if canImport(UIKit)
        if let image = UIImage(contentsOfFile: url.path) { return Image(uiImage: image) }
        #elseif canImport(AppKit)
        if let image = NSImage(contentsOf: url) { return Image(nsImage: image) }
        #endif
        return Image(systemName: "photo")
    }
}
