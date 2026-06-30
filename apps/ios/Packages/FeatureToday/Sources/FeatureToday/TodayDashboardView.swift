import SwiftUI
import DesignSystem

/// The gold-standard Today / Home dashboard (build bible §6.3), rendered with
/// demo data so it can be previewed without a backend. This is the calm landing
/// surface: greeting, the hero check-in card, gentle streak + 7-day mood, and
/// the "today" list with the safety affordance always one tap away.
public struct TodayDashboardView: View {
    @State private var showCheckIn = false

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                heroCard
                statsRow
                Text("Today").copeSectionLabel(CopeColor.ink2)
                    .padding(.top, 10)
                    .padding(.horizontal, 4)
                todayList
            }
            .padding(.horizontal, CopeSpacing.screenH)
            .padding(.top, 6)
            .padding(.bottom, 40)
        }
        .background(CopeColor.canvas.ignoresSafeArea())
        .sheet(isPresented: $showCheckIn) {
            CheckInTasteView()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Tuesday · Good morning").copeSectionLabel(CopeColor.teal)
                Text("Hi, Maya")
                    .font(CopeFont.display)
                    .foregroundStyle(CopeColor.ink)
            }
            Spacer()
            Text("M")
                .font(CopeFont.fraunces(17))
                .foregroundStyle(CopeColor.clay)
                .frame(width: 44, height: 44)
                .background(CopeColor.claySoft)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(CopeColor.line, lineWidth: 1))
        }
        .padding(.vertical, 10)
    }

    // MARK: Hero check-in card

    private var heroCard: some View {
        Button {
            showCheckIn = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text("Morning check-in").copeSectionLabel(.white.opacity(0.9))
                Text("How are you feeling today?")
                    .font(CopeFont.fraunces(22))
                    .foregroundStyle(.white)
                    .padding(.top, 7)
                Text("A gentle 2-minute reflection. Just where you are — no right answers.")
                    .font(CopeFont.callout)
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                HStack(spacing: 8) {
                    Text("Begin")
                    Image(systemName: "arrow.right")
                }
                .font(CopeFont.figtree(13.5, .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .background(heroBackground)
            .clipShape(RoundedRectangle(cornerRadius: CopeRadius.hero, style: .continuous))
            .shadow(color: CopeColor.teal.opacity(0.4), radius: 18, x: 0, y: 14)
        }
        .buttonStyle(.plain)
    }

    private var heroBackground: some View {
        CopeGradient.primary
            .overlay(alignment: .topTrailing) {
                Circle().fill(.white.opacity(0.10)).frame(width: 150, height: 150).offset(x: 30, y: -30)
            }
            .overlay(alignment: .bottomTrailing) {
                Circle().fill(.white.opacity(0.07)).frame(width: 110, height: 110).offset(x: -30, y: 50)
            }
    }

    // MARK: Stats

    private var statsRow: some View {
        HStack(spacing: 10) {
            streakCard
            moodWeekCard
        }
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Gentle streak")
                .font(CopeFont.figtree(12, .medium))
                .foregroundStyle(CopeColor.ink2)
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("11")
                    .font(CopeFont.numberMedium)
                    .foregroundStyle(CopeColor.ink)
                Text("days · 1 freeze left")
                    .font(CopeFont.figtree(12))
                    .foregroundStyle(CopeColor.ink3)
            }
        }
        .copeCard(padding: 14)
    }

    private var moodWeekCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mood, 7-day")
                .font(CopeFont.figtree(12, .medium))
                .foregroundStyle(CopeColor.ink2)
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(Array(Self.weekMoods.enumerated()), id: \.offset) { _, mood in
                    Capsule()
                        .fill(CopeMood.color(for: mood))
                        .frame(height: CGFloat(mood) / 10 * 26)
                        .opacity(0.85)
                }
            }
            .frame(height: 26)
        }
        .copeCard(padding: 14)
    }

    private static let weekMoods = [3, 5, 4, 7, 6, 8, 7]

    // MARK: Today list

    private var todayList: some View {
        VStack(spacing: 10) {
            TodayRow(
                icon: "pills.fill", iconTint: .teal,
                title: "Morning medications",
                subtitle: "Lamotrigine · Sertraline · 1 of 3 taken",
                trailing: .badge("2 due")
            ) {}
            TodayRow(
                icon: "checkmark.seal.fill", iconTint: .clay,
                title: "Weekly PHQ-9 check",
                subtitle: "From Dr. Alvarez · 5 minutes · due today",
                trailing: .chevron
            ) {}
            TodayRow(
                icon: "bubble.left.and.bubble.right.fill", iconTint: .teal,
                title: "Dr. Alvarez replied",
                subtitle: "“So glad the new dose is settling in…”",
                trailing: .chevron, showsUnread: true
            ) {}
            TodayRow(
                icon: "calendar", iconTint: .clay,
                title: "Visit Thursday — let's prepare",
                subtitle: "Pick what to talk about with Dr. Alvarez",
                trailing: .chevron
            ) {}
            SafetyButton {}
                .padding(.top, 6)
        }
    }
}

#Preview {
    TodayDashboardView()
}
