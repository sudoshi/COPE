import SwiftUI
import DesignSystem

/// The app shell (build bible §5): five slots — Today · Insights · [+ FAB] ·
/// Care · You — with a raised center check-in FAB presenting the check-in as a
/// full-screen cover. Insights/Care/You are on-brand placeholders for now.
public struct MainShellView: View {
    @State private var tab: Tab = .today
    @State private var showCheckIn = false

    public init() {}

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
            CheckInView()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .today:
            TodayDashboardView()
        case .insights:
            PlaceholderTab(
                icon: "chart.line.uptrend.xyaxis",
                title: "Insights",
                subtitle: "Patterns from your check-ins — yours alone to share."
            )
        case .care:
            PlaceholderTab(
                icon: "bubble.left.and.bubble.right.fill",
                title: "Your care team",
                subtitle: "Secure two-way messaging with your team — coming next."
            )
        case .you:
            PlaceholderTab(
                icon: "person.crop.circle",
                title: "You",
                subtitle: "Privacy, consent, and app settings — coming next."
            )
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

/// On-brand placeholder for tabs not yet built.
private struct PlaceholderTab: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(CopeColor.tealInk)
                .frame(width: 72, height: 72)
                .background(CopeColor.tealSoft)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            Text(title)
                .font(CopeFont.title)
                .foregroundStyle(CopeColor.ink)
            Text(subtitle)
                .font(CopeFont.body)
                .foregroundStyle(CopeColor.ink2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

#Preview {
    MainShellView()
}
