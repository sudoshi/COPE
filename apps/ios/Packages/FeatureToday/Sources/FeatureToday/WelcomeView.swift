import SwiftUI
import DesignSystem

/// The re-imagined start / sign-in screen — a calm front door. A slowly
/// breathing brand orb (inhale/exhale with outward ripples) over drifting
/// ambient color, a time-aware greeting, and a gentle translateY entrance.
/// Designed to soothe and invite, and to make returning feel effortless.
public struct WelcomeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false
    @State private var drift = false
    @State private var appeared = false

    private let onGetStarted: () -> Void
    private let onSignIn: () -> Void

    public init(onGetStarted: @escaping () -> Void = {}, onSignIn: @escaping () -> Void = {}) {
        self.onGetStarted = onGetStarted
        self.onSignIn = onSignIn
    }

    public var body: some View {
        ZStack {
            ambient
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                BreathingOrb(breathe: breathe, reduceMotion: reduceMotion)
                    .frame(width: 220, height: 220)
                    .padding(.bottom, 44)

                VStack(spacing: 0) {
                    Text(greeting).copeSectionLabel(CopeColor.teal)
                    Text("Welcome to COPE")
                        .font(CopeFont.display).foregroundStyle(CopeColor.ink)
                        .multilineTextAlignment(.center)
                        .padding(.top, 7)
                    Text("A calmer, more connected way to stay close to your care team — built around how you actually feel.")
                        .font(CopeFont.body).foregroundStyle(CopeColor.ink2)
                        .multilineTextAlignment(.center)
                        .padding(.top, 13).padding(.horizontal, 34)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .offset(y: appeared ? 0 : 14)

                Spacer(minLength: 24)

                VStack(spacing: 16) {
                    Button("Get started") { onGetStarted() }
                        .buttonStyle(.copePrimary)
                    Button { onSignIn() } label: {
                        Text("I already have an account")
                            .font(CopeFont.bodyStrong)
                            .foregroundStyle(CopeColor.tealInk)
                    }
                    .buttonStyle(.plain)
                    trustLine.padding(.top, 6)
                }
                .padding(.horizontal, 28)
                .offset(y: appeared ? 0 : 18)
                .padding(.bottom, 14)
            }
        }
        .background(CopeColor.canvas.ignoresSafeArea())
        .onAppear(perform: start)
    }

    private var ambient: some View {
        ZStack {
            Circle().fill(CopeColor.teal.opacity(0.12)).frame(width: 340, height: 340).blur(radius: 90)
                .offset(x: drift ? -110 : -80, y: drift ? -280 : -320)
            Circle().fill(CopeColor.clay.opacity(0.11)).frame(width: 320, height: 320).blur(radius: 90)
                .offset(x: drift ? 130 : 100, y: drift ? 300 : 350)
            Circle().fill(CopeColor.amber.opacity(0.06)).frame(width: 260, height: 260).blur(radius: 90)
                .offset(x: drift ? -150 : -120, y: drift ? 220 : 180)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 13).repeatForever(autoreverses: true), value: drift)
        .ignoresSafeArea()
    }

    private var trustLine: some View {
        Label("Private & encrypted · 988 lifeline built in", systemImage: "lock.fill")
            .font(CopeFont.figtree(11.5))
            .foregroundStyle(CopeColor.ink3)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private func start() {
        guard !reduceMotion else { appeared = true; return }
        withAnimation(.easeOut(duration: 0.7)) { appeared = true }
        breathe = true
        drift = true
    }
}

/// The brand orb: a soft teal sphere that gently breathes (inhale/exhale) while
/// concentric rings ripple outward — a quiet invitation to slow down.
private struct BreathingOrb: View {
    let breathe: Bool
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            // Outward breath ripples (staggered).
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(CopeColor.teal.opacity(0.18), lineWidth: 1.5)
                    .frame(width: 200, height: 200)
                    .scaleEffect(breathe ? 1.0 : 0.5)
                    .opacity(breathe ? 0 : 0.55)
                    .animation(
                        reduceMotion ? nil
                        : .easeOut(duration: 5.6).repeatForever(autoreverses: false).delay(Double(index) * 1.85),
                        value: breathe
                    )
            }

            // Soft glow that swells with the breath.
            Circle().fill(CopeColor.teal).frame(width: 168, height: 168).blur(radius: 48)
                .opacity(0.32)
                .scaleEffect(breathe ? 1.1 : 0.9)
                .animation(reduceMotion ? nil : .easeInOut(duration: 5.6).repeatForever(autoreverses: true), value: breathe)

            // Core orb.
            Circle()
                .fill(CopeGradient.primary)
                .frame(width: 136, height: 136)
                .overlay(
                    Circle().fill(.white.opacity(0.20)).frame(width: 64, height: 64)
                        .offset(x: -24, y: -28).blur(radius: 10)
                )
                .overlay(Text("c").font(CopeFont.fraunces(48)).foregroundStyle(.white))
                .scaleEffect(breathe ? 1.06 : 0.95)
                .shadow(color: CopeColor.teal.opacity(0.5), radius: 32, x: 0, y: 18)
                .animation(reduceMotion ? nil : .easeInOut(duration: 5.6).repeatForever(autoreverses: true), value: breathe)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    WelcomeView()
}
