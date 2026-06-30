import SwiftUI
import Charts
import DesignSystem

/// Insights tab (build bible §6.7): a calm read of patterns. Demo data for now.
public struct InsightsView: View {
    public init() {}

    private struct MoodPoint: Identifiable {
        let id = UUID()
        let day: Int
        let value: Double
    }

    private let mood: [MoodPoint] = [
        4.8, 4.5, 5.0, 4.6, 5.4, 5.0, 5.8, 6.0, 5.6, 6.4, 6.2, 6.6, 6.4, 7.0
    ].enumerated().map { MoodPoint(day: $0.offset, value: $0.element) }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Insights").font(CopeFont.display).foregroundStyle(CopeColor.ink)
                    Text("Patterns from your check-ins — yours alone to share.")
                        .font(CopeFont.body).foregroundStyle(CopeColor.ink2)
                }
                .padding(.top, 4)
                .padding(.bottom, 6)

                moodCard
                correlationCard
                statsRow
                aiCard
            }
            .padding(.horizontal, CopeSpacing.screenH)
            .padding(.bottom, 40)
        }
        .background(CopeColor.canvas.ignoresSafeArea())
    }

    private var moodCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Mood").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
                Spacer()
                Text("Last 14 days").font(CopeFont.caption).foregroundStyle(CopeColor.ink3)
            }
            Chart(mood) { point in
                AreaMark(x: .value("Day", point.day), y: .value("Mood", point.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(LinearGradient(
                        colors: [CopeColor.teal.opacity(0.28), CopeColor.teal.opacity(0)],
                        startPoint: .top, endPoint: .bottom))
                LineMark(x: .value("Day", point.day), y: .value("Mood", point.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(CopeColor.teal)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                if point.day == mood.last?.day {
                    PointMark(x: .value("Day", point.day), y: .value("Mood", point.value))
                        .foregroundStyle(CopeColor.teal)
                        .symbolSize(80)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...10)
            .frame(height: 96)
            HStack {
                Text("Jun 8"); Spacer(); Text("Today")
            }
            .font(CopeFont.figtree(11)).foregroundStyle(CopeColor.ink3)
        }
        .copeCard(padding: 18, radius: CopeRadius.cardLarge)
    }

    private var correlationCard: some View {
        FeatureCard(tint: .teal) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(CopeColor.teal)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    Text("A pattern worth noticing").copeSectionLabel(CopeColor.tealInk)
                }
                (Text("On days you moved your body, your mood the next morning was ")
                 + Text("+1.8 higher").foregroundColor(CopeColor.teal)
                 + Text(" on average."))
                    .font(CopeFont.sectionTitle)
                    .foregroundStyle(CopeColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Sleep, avg").font(CopeFont.figtree(12.5, .medium)).foregroundStyle(CopeColor.ink2)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("6.8").font(CopeFont.numberMedium).foregroundStyle(CopeColor.ink)
                    Text("h").font(CopeFont.figtree(14)).foregroundStyle(CopeColor.ink3)
                }
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach([0.6, 0.8, 0.5, 0.9, 0.7, 0.85], id: \.self) { h in
                        Capsule().fill(CopeColor.teal.opacity(0.55)).frame(height: 24 * h)
                    }
                }
                .frame(height: 24)
            }
            .copeCard(padding: 16, radius: CopeRadius.card)

            VStack(alignment: .leading, spacing: 8) {
                Text("PHQ-9").font(CopeFont.figtree(12.5, .medium)).foregroundStyle(CopeColor.ink2)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("9").font(CopeFont.numberMedium).foregroundStyle(CopeColor.ink)
                    Text("↓ from 14").font(CopeFont.figtree(12, .semibold)).foregroundStyle(CopeColor.teal)
                }
                Text("Moving from moderate toward mild")
                    .font(CopeFont.figtree(11.5)).foregroundStyle(CopeColor.ink3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .copeCard(padding: 16, radius: CopeRadius.card)
        }
    }

    private var aiCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15))
                    .foregroundStyle(CopeColor.clay)
                    .frame(width: 30, height: 30)
                    .background(CopeColor.claySoft)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                Text("Weekly reflection").font(CopeFont.bodyStrong).foregroundStyle(CopeColor.ink)
            }
            Text("Your sleep steadied this week and your mornings trended brighter. Anxiety still rises midweek — worth a word with Dr. Alvarez.")
                .font(CopeFont.callout).foregroundStyle(CopeColor.ink2)
                .fixedSize(horizontal: false, vertical: true)
            Label("Generated privately, with your consent · not a diagnosis", systemImage: "lock.fill")
                .font(CopeFont.figtree(11)).foregroundStyle(CopeColor.ink3)
        }
        .copeCard(padding: 18, radius: CopeRadius.cardLarge)
    }
}

#Preview {
    InsightsView()
}
