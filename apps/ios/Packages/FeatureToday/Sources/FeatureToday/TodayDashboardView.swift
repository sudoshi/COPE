import SwiftUI
import DesignSystem

/// The gold-standard Today / Home dashboard (build bible §6.3). Data-driven via
/// `TodayModel`; defaults to `.sample` so previews and the mock build keep
/// working until the app injects real data.
public struct TodayDashboardView: View {
    @State private var showCheckIn = false
    @State private var showSafety = false
    @State private var showMeds = false
    @State private var showAssessment = false
    @State private var showPreVisit = false

    private let model: TodayModel
    private let medications: MedicationsModel
    /// Switches the shell to the Care tab (the message row).
    private let onOpenCare: () -> Void

    public init(model: TodayModel = .sample, medications: MedicationsModel = .sample, onOpenCare: @escaping () -> Void = {}) {
        self.model = model
        self.medications = medications
        self.onOpenCare = onOpenCare
    }

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
        .copeFullCover(isPresented: $showCheckIn) { CheckInView() }
        .copeFullCover(isPresented: $showSafety) { SafetyPlanView() }
        .copeFullCover(isPresented: $showMeds) { MedicationsView(model: medications) }
        .copeFullCover(isPresented: $showAssessment) { AssessmentView() }
        .copeFullCover(isPresented: $showPreVisit) { PreVisitView() }
        .debugAutoOpen("meds") { showMeds = true }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(model.greeting).copeSectionLabel(CopeColor.teal)
                Text("Hi, \(model.name)")
                    .font(CopeFont.display)
                    .foregroundStyle(CopeColor.ink)
            }
            Spacer()
            Text(model.avatarInitial)
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
                Text(model.heroLabel).copeSectionLabel(.white.opacity(0.9))
                Text(model.heroQuestion)
                    .font(CopeFont.fraunces(22))
                    .foregroundStyle(.white)
                    .padding(.top, 7)
                    .fixedSize(horizontal: false, vertical: true)
                Text(model.heroSubtitle)
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
                Text("\(model.streakDays)")
                    .font(CopeFont.numberMedium)
                    .foregroundStyle(CopeColor.ink)
                Text(model.streakDetail)
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
                ForEach(Array(model.weekMoods.enumerated()), id: \.offset) { _, mood in
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

    // MARK: Today list

    private var todayList: some View {
        VStack(spacing: 10) {
            ForEach(model.tasks) { task in
                TodayRow(
                    icon: icon(for: task.kind),
                    iconTint: tint(for: task.kind),
                    title: task.title,
                    subtitle: task.subtitle,
                    trailing: task.badge.map { .badge($0) } ?? .chevron,
                    showsUnread: task.showsUnread
                ) { handle(task.kind) }
            }
            SafetyButton { showSafety = true }
                .padding(.top, 6)
        }
    }

    private func icon(for kind: TodayTask.Kind) -> String {
        switch kind {
        case .medications: return "pills.fill"
        case .assessment: return "checkmark.seal.fill"
        case .message: return "bubble.left.and.bubble.right.fill"
        case .preVisit: return "calendar"
        }
    }

    private func tint(for kind: TodayTask.Kind) -> TodayRow.IconTint {
        switch kind {
        case .medications, .message: return .teal
        case .assessment, .preVisit: return .clay
        }
    }

    private func handle(_ kind: TodayTask.Kind) {
        switch kind {
        case .medications: showMeds = true
        case .assessment: showAssessment = true
        case .message: onOpenCare()
        case .preVisit: showPreVisit = true
        }
    }
}

#Preview {
    TodayDashboardView()
}
