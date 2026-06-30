import SwiftUI
import FeatureToday

@main
struct COPEApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var session = SessionViewModel()

    init() {
        // Register bundled Fraunces/Figtree fonts before the first view renders.
        CopeUI.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .task {
                    #if DEBUG
                    if ProcessInfo.processInfo.environment["COPE_UI_TEST_DISABLE_SESSION_RESTORE"] == "1" {
                        session.prepareUnauthenticatedUITestSession()
                        return
                    }
                    #endif

                    await session.restoreSession()

                    #if DEBUG
                    // QA hook: auto sign-in from env so the Simulator can verify
                    // the full login → real-data path without typing.
                    let env = ProcessInfo.processInfo.environment
                    if !session.isAuthenticated,
                       let email = env["COPE_TEST_EMAIL"], !email.isEmpty,
                       let password = env["COPE_TEST_PASSWORD"], !password.isEmpty {
                        await session.signIn(email: email, password: password)
                    }
                    #endif
                }
        }
    }
}
