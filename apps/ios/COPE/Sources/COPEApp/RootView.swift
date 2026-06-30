import SwiftUI
import FeatureToday

struct RootView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        content
            .onOpenURL { url in
                session.handleOpenURL(url)
            }
    }

    /// DEBUG-only: launch straight into the gold-standard UI without auth/backend
    /// when `COPE_UI_PREVIEW=1`. Production behavior is unchanged.
    @ViewBuilder
    private var content: some View {
        if Self.isUIPreview {
            TodayDashboardView()
        } else {
            appContent
        }
    }

    private static var isUIPreview: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["COPE_UI_PREVIEW"] == "1"
        #else
        return false
        #endif
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
