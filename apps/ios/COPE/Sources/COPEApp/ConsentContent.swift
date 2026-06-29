import Foundation

extension PatientConsentType {
    static let requiredOnboardingConsents: [PatientConsentType] = [
        .termsOfService,
        .privacyPolicy,
    ]

    static let appControls: [PatientConsentType] = [
        .journalSharing,
        .dataResearch,
        .aiInsights,
        .emergencyContact,
        .pushNotifications,
    ]

    var title: String {
        switch self {
        case .shareWithClinician:
            return "Care team sharing"
        case .shareJournalWithClinician:
            return "Journal care sharing"
        case .researchParticipation:
            return "Research participation"
        case .dataExport:
            return "Data export"
        case .termsOfService:
            return "Terms of Service"
        case .privacyPolicy:
            return "Privacy Policy"
        case .journalSharing:
            return "Journal sharing"
        case .dataResearch:
            return "Research data"
        case .aiInsights:
            return "AI insights"
        case .emergencyContact:
            return "Emergency contact"
        case .pushNotifications:
            return "Push notifications"
        }
    }

    var subtitle: String {
        switch self {
        case .shareWithClinician:
            return "Allow your care team to review shared app data for treatment."
        case .shareJournalWithClinician:
            return "Allow selected journal content to be shared for clinical review."
        case .researchParticipation:
            return "Allow participation in approved research workflows."
        case .dataExport:
            return "Allow export of your data when requested through supported workflows."
        case .termsOfService:
            return "Required to create and use a COPE patient account."
        case .privacyPolicy:
            return "Required acknowledgement of how COPE handles patient information."
        case .journalSharing:
            return "Share selected journal entries with your care team."
        case .dataResearch:
            return "Allow de-identified data export for research workflows."
        case .aiInsights:
            return "Allow AI-assisted summaries and trend insights."
        case .emergencyContact:
            return "Allow emergency contact use during safety events."
        case .pushNotifications:
            return "Allow device notifications for reminders and care requests."
        }
    }

    var systemImage: String {
        switch self {
        case .shareWithClinician:
            return "stethoscope"
        case .shareJournalWithClinician:
            return "book.closed.fill"
        case .researchParticipation:
            return "cross.vial.fill"
        case .dataExport:
            return "square.and.arrow.up.fill"
        case .termsOfService:
            return "doc.text.fill"
        case .privacyPolicy:
            return "lock.shield.fill"
        case .journalSharing:
            return "book.pages.fill"
        case .dataResearch:
            return "chart.xyaxis.line"
        case .aiInsights:
            return "sparkles"
        case .emergencyContact:
            return "person.crop.circle.badge.exclamationmark"
        case .pushNotifications:
            return "bell.badge.fill"
        }
    }
}
