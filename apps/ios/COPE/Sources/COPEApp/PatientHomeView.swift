import SwiftUI

struct PatientHomeView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        TabView {
            TodayView(apiClient: session.apiClient)
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }

            AssessmentsView(apiClient: session.apiClient)
                .tabItem {
                    Label("Assessments", systemImage: "list.clipboard")
                }

            CareView(apiClient: session.apiClient)
                .tabItem {
                    Label("Care", systemImage: "cross.case.fill")
                }

            ProfileTabView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(CopeColor.primary)
    }
}

private struct ProfileTabView: View {
    @EnvironmentObject private var session: SessionViewModel
    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if let profile = session.profile {
                        ProfileSummaryView(profile: profile)
                    } else {
                        ProgressView()
                            .tint(CopeColor.primary)
                            .frame(maxWidth: .infinity, minHeight: 220)
                    }

                    if let errorMessage = session.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(CopeColor.danger)
                    }
                }
                .padding(20)
            }
            .background(CopeColor.background)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isRefreshing)
                    .accessibilityLabel("Refresh profile")

                    Button(role: .destructive) {
                        Task {
                            await session.signOut()
                        }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                    .accessibilityLabel("Sign out")
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.profile?.displayName ?? "COPE")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(CopeColor.text)

            Text(session.profile?.email ?? "Patient workspace")
                .font(.system(size: 15))
                .foregroundStyle(CopeColor.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func refresh() async {
        isRefreshing = true
        do {
            try await session.refreshProfile()
        } catch {
            session.errorMessage = "Profile could not be refreshed."
        }
        isRefreshing = false
    }
}

private struct ProfileSummaryView: View {
    let profile: PatientProfileSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                MetricTile(title: "Status", value: profile.status.capitalized, color: CopeColor.success)
                MetricTile(title: "Risk", value: profile.riskLevel.capitalized, color: CopeColor.warning)
            }

            HStack(spacing: 12) {
                MetricTile(title: "Streak", value: "\(profile.trackingStreak)", color: CopeColor.primary)
                MetricTile(title: "Best", value: "\(profile.longestStreak)", color: CopeColor.primary)
            }

            VStack(alignment: .leading, spacing: 12) {
                ProfileRow(label: "Timezone", value: profile.timezone)
                ProfileRow(label: "Onboarding", value: profile.onboardingComplete ? "Complete" : "In progress")

                if let lastCheckinAt = profile.lastCheckinAt {
                    ProfileRow(label: "Last check-in", value: lastCheckinAt)
                }
            }
            .padding(16)
            .background(CopeColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(CopeColor.border, lineWidth: 1)
            )
        }
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CopeColor.textMuted)

            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(CopeColor.text)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .padding(14)
        .background(CopeColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.6), lineWidth: 1)
        )
    }
}

private struct ProfileRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(CopeColor.textMuted)
                .frame(width: 110, alignment: .leading)

            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(CopeColor.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    PatientHomeView()
        .environmentObject(SessionViewModel())
}
