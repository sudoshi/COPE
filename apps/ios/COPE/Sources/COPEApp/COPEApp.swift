import SwiftUI

@main
struct COPEApp: App {
    @StateObject private var session = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .task {
                    await session.restoreSession()
                }
        }
    }
}
