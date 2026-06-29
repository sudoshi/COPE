import SwiftUI

@main
struct COPEApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var session = SessionViewModel()

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
                }
        }
    }
}
