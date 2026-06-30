import SwiftUI
import FeatureToday

struct RootView: View {
    @EnvironmentObject private var session: SessionViewModel
    @State private var entered = false

    var body: some View {
        content
            .onOpenURL { url in
                session.handleOpenURL(url)
            }
    }

    /// Internal preview / TestFlight build: launch the gold-standard UI directly.
    /// The auth-gated production flow is preserved in `appContent` and returns
    /// when real data wiring lands (opt in now with `COPE_LEGACY_AUTH=1`).
    @ViewBuilder
    private var content: some View {
        #if DEBUG
        switch ProcessInfo.processInfo.environment["COPE_PREVIEW_SCREEN"] {
        case "welcome": WelcomeView()
        case "checkin": CheckInView()
        case "safety": SafetyPlanView()
        case "assessment": AssessmentView()
        case "meds": MedicationsView()
        case "journal": JournalView()
        case "previsit": PreVisitView()
        case "onboarding": OnboardingView()
        default: defaultContent
        }
        #else
        defaultContent
        #endif
    }

    @ViewBuilder
    private var defaultContent: some View {
        if Self.useLegacyAuthFlow {
            appContent
        } else {
            ZStack {
                if entered {
                    MainShellView().transition(.opacity)
                } else {
                    WelcomeView(
                        onGetStarted: { enterApp() },
                        onSignIn: { enterApp() }
                    )
                    .transition(.opacity)
                }
            }
        }
    }

    private func enterApp() {
        withAnimation(.easeInOut(duration: 0.5)) { entered = true }
    }

    private static var useLegacyAuthFlow: Bool {
        ProcessInfo.processInfo.environment["COPE_LEGACY_AUTH"] == "1"
    }

    private var appContent: some View {
        ZStack {
            CopeColor.background
                .ignoresSafeArea()

            if session.isRestoring {
                ProgressView()
                    .tint(CopeColor.primary)
            } else if session.isAuthenticated {
                if let profile = session.profile {
                    if session.requiredConsentsSatisfied == true, profile.onboardingComplete {
                        PatientHomeView()
                    } else if session.requiredConsentsSatisfied == true {
                        OnboardingIntakeView()
                    } else if session.requiredConsentsSatisfied == false {
                        OnboardingConsentView()
                    } else {
                        ProgressView()
                            .tint(CopeColor.primary)
                    }
                } else {
                    ProgressView()
                        .tint(CopeColor.primary)
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(SessionViewModel())
}
