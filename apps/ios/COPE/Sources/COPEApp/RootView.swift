import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
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
        .onOpenURL { url in
            session.handleOpenURL(url)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(SessionViewModel())
}
