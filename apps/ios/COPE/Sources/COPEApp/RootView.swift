import SwiftUI
import FeatureToday

struct RootView: View {
    @EnvironmentObject private var session: SessionViewModel
    @State private var showLogin = false

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
            authedFlow
        }
    }

    /// Real auth gating the gold-standard UI: Welcome → real login → the app,
    /// seeded with the authenticated patient's name + streak. Other screens
    /// still use sample content until their endpoints are wired.
    @ViewBuilder
    private var authedFlow: some View {
        if session.isRestoring {
            loading
        } else if session.isAuthenticated, let profile = session.profile {
            MainShellView(
                today: Self.todayModel(for: profile),
                profile: Self.profileModel(for: profile)
            )
        } else if session.isAuthenticated {
            loading
        } else if showLogin {
            LoginView()
        } else {
            WelcomeView(
                mode: .firstRun,
                onGetStarted: { showLogin = true },
                onUnlock: { showLogin = true },
                onSignIn: { showLogin = true }
            )
        }
    }

    private var loading: some View {
        ZStack {
            CopeColor.background.ignoresSafeArea()
            ProgressView().tint(CopeColor.primary)
        }
    }

    private static func todayModel(for profile: PatientProfileSummary) -> TodayModel {
        var model = TodayModel.sample
        model.name = profile.displayName.split(separator: " ").first.map(String.init) ?? profile.displayName
        model.greeting = greetingLine()
        model.streakDays = profile.trackingStreak
        return model
    }

    private static func profileModel(for profile: PatientProfileSummary) -> ProfileModel {
        var model = ProfileModel.sample
        model.name = profile.displayName
        return model
    }

    private static func greetingLine() -> String {
        let now = Date()
        let weekday = now.formatted(.dateTime.weekday(.wide))
        let hour = Calendar.current.component(.hour, from: now)
        let timeOfDay = hour < 12 ? "Good morning" : (hour < 17 ? "Good afternoon" : "Good evening")
        return "\(weekday) · \(timeOfDay)"
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
