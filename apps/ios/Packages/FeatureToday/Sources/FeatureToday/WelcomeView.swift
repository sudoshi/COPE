import SwiftUI
import DesignSystem
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

/// The re-imagined start / sign-in screen — a calm front door. A slowly
/// breathing brand orb (inhale/exhale with outward ripples) over drifting
/// ambient color, a time-aware greeting, and a gentle translateY entrance.
///
/// Two modes: `.firstRun` invites a new visitor; `.returning` greets a known
/// patient by name and offers a one-tap Face ID unlock — making coming back
/// feel effortless (the core stickiness lever).
public struct WelcomeView: View {
    public enum Mode {
        case firstRun, returning
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false
    @State private var appeared = false

    private let mode: Mode
    private let userName: String?
    private let onGetStarted: () -> Void
    private let onUnlock: () -> Void
    private let onSignIn: () -> Void

    public init(
        mode: Mode = .firstRun,
        userName: String? = nil,
        onGetStarted: @escaping () -> Void = {},
        onUnlock: @escaping () -> Void = {},
        onSignIn: @escaping () -> Void = {}
    ) {
        self.mode = mode
        self.userName = userName
        self.onGetStarted = onGetStarted
        self.onUnlock = onUnlock
        self.onSignIn = onSignIn
    }

    public var body: some View {
        ZStack {
            PhotoBackground(reduceMotion: reduceMotion)
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                BreathingOrb(breathe: breathe, reduceMotion: reduceMotion)
                    .frame(width: 220, height: 220)
                    .padding(.bottom, 44)
                copyBlock.offset(y: appeared ? 0 : 14)
                Spacer(minLength: 24)
                actions.offset(y: appeared ? 0 : 18).padding(.bottom, 14)
            }
        }
        .background(CopeColor.canvas.ignoresSafeArea())
        .onAppear(perform: start)
    }

    // MARK: Copy

    @ViewBuilder
    private var copyBlock: some View {
        VStack(spacing: 0) {
            Text(greeting).copeSectionLabel(CopeColor.teal)
            Text(title)
                .font(CopeFont.display).foregroundStyle(CopeColor.ink)
                .multilineTextAlignment(.center)
                .padding(.top, 7)
            Text(subtitle)
                .font(CopeFont.body).foregroundStyle(CopeColor.ink2)
                .multilineTextAlignment(.center)
                .padding(.top, 13).padding(.horizontal, 34)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var title: String {
        switch mode {
        case .firstRun: return "Welcome to COPE"
        case .returning: return userName.map { "Welcome back, \($0)" } ?? "Welcome back"
        }
    }

    private var subtitle: String {
        switch mode {
        case .firstRun:
            return "A calmer, more connected way to stay close to your care team — built around how you actually feel."
        case .returning:
            return "Your care team is right here. Let's pick up where you left off."
        }
    }

    // MARK: Actions

    @ViewBuilder
    private var actions: some View {
        VStack(spacing: 16) {
            switch mode {
            case .firstRun:
                Button("Get started") { onGetStarted() }
                    .buttonStyle(.copePrimary)
                signInLink("I already have an account")
            case .returning:
                Button { biometricUnlock() } label: {
                    Label("Unlock with Face ID", systemImage: "faceid")
                }
                .buttonStyle(.copePrimary)
                signInLink(userName.map { "Not \($0)? Sign in" } ?? "Use a different account")
            }
            trustLine.padding(.top, 6)
        }
        .padding(.horizontal, 28)
    }

    private func signInLink(_ text: String) -> some View {
        Button { onSignIn() } label: {
            Text(text).font(CopeFont.bodyStrong).foregroundStyle(CopeColor.tealInk)
        }
        .buttonStyle(.plain)
    }

    private var trustLine: some View {
        Label("Private & encrypted · 988 lifeline built in", systemImage: "lock.fill")
            .font(CopeFont.figtree(11.5))
            .foregroundStyle(CopeColor.ink3)
    }

    // MARK: Behavior

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
    }

    /// Attempts a biometric unlock. On device, gates entry on a successful
    /// Face ID / Touch ID match; where biometrics aren't available (e.g. the
    /// Simulator) it falls through so the demo still flows. Production binds
    /// this to a Keychain/Secure-Enclave crypto op (build bible §8).
    private func biometricUnlock() {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock COPE") { success, _ in
                if success {
                    DispatchQueue.main.async { onUnlock() }
                }
            }
            return
        }
        #endif
        onUnlock()
    }
}

/// The brand orb: a soft teal sphere that gently breathes (inhale/exhale) while
/// concentric rings ripple outward — a quiet invitation to slow down.
private struct BreathingOrb: View {
    let breathe: Bool
    let reduceMotion: Bool

    var body: some View {
        ZStack {
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

            Circle().fill(CopeColor.teal).frame(width: 168, height: 168).blur(radius: 48)
                .opacity(0.32)
                .scaleEffect(breathe ? 1.1 : 0.9)
                .animation(reduceMotion ? nil : .easeInOut(duration: 5.6).repeatForever(autoreverses: true), value: breathe)

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

#Preview("First run") { WelcomeView(mode: .firstRun) }
#Preview("Returning") { WelcomeView(mode: .returning, userName: "Maya") }
