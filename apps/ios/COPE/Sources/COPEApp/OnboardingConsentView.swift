import SwiftUI

struct OnboardingConsentView: View {
    @EnvironmentObject private var session: SessionViewModel
    @State private var acceptedTypes: Set<PatientConsentType> = []
    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Consent")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(CopeColor.text)

                        Text(session.profile?.displayName ?? "Patient profile")
                            .font(.system(size: 15))
                            .foregroundStyle(CopeColor.textMuted)
                    }

                    VStack(spacing: 12) {
                        ForEach(PatientConsentType.requiredOnboardingConsents) { type in
                            ConsentAcceptanceRow(
                                type: type,
                                isOn: Binding(
                                    get: { acceptedTypes.contains(type) },
                                    set: { isAccepted in
                                        if isAccepted {
                                            acceptedTypes.insert(type)
                                        } else {
                                            acceptedTypes.remove(type)
                                        }
                                    }
                                )
                            )
                        }
                    }

                    if let errorMessage = session.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(CopeColor.danger)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button {
                        Task {
                            await session.grantRequiredConsents(acceptedTypes: acceptedTypes)
                        }
                    } label: {
                        Label(session.isLoading ? "Saving Consent" : "Continue", systemImage: "checkmark.shield.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(canContinue && !session.isLoading ? CopeColor.primary : CopeColor.primaryDark)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(!canContinue || session.isLoading)

                    Button {
                        Task {
                            await refreshConsentStatus()
                        }
                    } label: {
                        Label(isRefreshing ? "Refreshing" : "Refresh", systemImage: "arrow.clockwise")
                            .font(.system(size: 15, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(CopeColor.text)
                    .background(CopeColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(CopeColor.border, lineWidth: 1)
                    )
                    .disabled(isRefreshing || session.isLoading)
                }
                .padding(24)
                .frame(maxWidth: 560, alignment: .leading)
            }
            .background(CopeColor.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
        .task {
            acceptedTypes.formUnion(session.grantedRequiredConsentTypes)
            if session.requiredConsentsSatisfied == nil || session.errorMessage != nil {
                await refreshConsentStatus()
            }
        }
        .onChange(of: session.grantedRequiredConsentTypes) {
            acceptedTypes.formUnion(session.grantedRequiredConsentTypes)
        }
    }

    private var canContinue: Bool {
        Set(PatientConsentType.requiredOnboardingConsents).isSubset(of: acceptedTypes)
    }

    private func refreshConsentStatus() async {
        isRefreshing = true
        await session.refreshRequiredConsentStatus()
        acceptedTypes.formUnion(session.grantedRequiredConsentTypes)
        isRefreshing = false
    }
}

struct ConsentAcceptanceRow: View {
    let type: PatientConsentType
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: type.systemImage)
                    .foregroundStyle(CopeColor.primary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CopeColor.text)

                    Text(type.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(CopeColor.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .toggleStyle(.switch)
        .tint(CopeColor.primary)
        .padding(16)
        .background(CopeColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(CopeColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingConsentView()
        .environmentObject(SessionViewModel())
}
