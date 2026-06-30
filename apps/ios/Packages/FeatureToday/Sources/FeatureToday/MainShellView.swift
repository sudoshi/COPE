import SwiftUI
import DesignSystem

/// The app shell (build bible §5): five slots — Today · Insights · [+ FAB] ·
/// Care · You — with a raised center check-in FAB presenting the check-in as a
/// full-screen cover. Insights/Care/You are on-brand placeholders for now.
public struct MainShellView: View {
    @State private var tab: Tab
    @State private var showCheckIn = false

    private let today: TodayModel
    private let profile: ProfileModel
    private let onCheckInSubmit: (CheckInResult) -> Void

    public init(
        today: TodayModel = .sample,
        profile: ProfileModel = .sample,
        onCheckInSubmit: @escaping (CheckInResult) -> Void = { _ in }
    ) {
        self.today = today
        self.profile = profile
        self.onCheckInSubmit = onCheckInSubmit
        var initial: Tab = .today
        #if DEBUG
        switch ProcessInfo.processInfo.environment["COPE_PREVIEW_TAB"] {
        case "insights": initial = .insights
        case "care": initial = .care
        case "you": initial = .you
        default: break
        }
        #endif
        _tab = State(initialValue: initial)
    }

    enum Tab: Hashable {
        case today, insights, care, you
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            CopeColor.canvas.ignoresSafeArea()

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 58) }

            tabBar
        }
        .copeFullCover(isPresented: $showCheckIn) {
            CheckInView(onSubmit: onCheckInSubmit)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .today: TodayDashboardView(model: today, onOpenCare: { tab = .care })
        case .insights: InsightsView()
        case .care: CareView()
        case .you: ProfileView(model: profile)
        }
    }

    // MARK: Tab bar

    private var tabBar: some View {
        HStack(alignment: .bottom, spacing: 0) {
            tabButton(.today, icon: "house.fill", label: "Today")
            tabButton(.insights, icon: "chart.line.uptrend.xyaxis", label: "Insights")
            fab
            tabButton(.care, icon: "bubble.left.and.bubble.right.fill", label: "Care")
            tabButton(.you, icon: "person.crop.circle", label: "You")
        }
        .padding(.horizontal, 16)
        .padding(.top, 9)
        .padding(.bottom, 4)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(CopeColor.line2).frame(height: 1)
        }
    }

    private func tabButton(_ target: Tab, icon: String, label: String) -> some View {
        let active = tab == target
        return Button {
            tab = target
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 21, weight: .regular))
                Text(label).font(CopeFont.figtree(10, .semibold))
            }
            .foregroundStyle(active ? CopeColor.teal : CopeColor.ink3)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(active ? [.isSelected, .isButton] : .isButton)
    }

    private var fab: some View {
        Button {
            showCheckIn = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(CopeGradient.primary)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(CopeColor.canvas, lineWidth: 4))
                .shadow(color: CopeColor.teal.opacity(0.5), radius: 12, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .frame(width: 64)
        .offset(y: -18)
        .accessibilityLabel("Start check-in")
    }
}

#Preview {
    MainShellView()
}
