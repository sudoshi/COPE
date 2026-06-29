import SwiftUI

struct OnboardingIntakeView: View {
    @EnvironmentObject private var session: SessionViewModel
    @State private var primaryConcern = ""
    @State private var emergencyContactName = ""
    @State private var emergencyContactPhone = ""
    @State private var emergencyContactRelationship = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Intake")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(CopeColor.text)

                        Text(session.profile?.displayName ?? "Patient profile")
                            .font(.system(size: 15))
                            .foregroundStyle(CopeColor.textMuted)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Primary Concern")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CopeColor.text)

                        ZStack(alignment: .topLeading) {
                            if primaryConcern.isEmpty {
                                Text("What would you like your care team to know first?")
                                    .font(.system(size: 15))
                                    .foregroundStyle(CopeColor.textMuted)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 8)
                            }

                            TextEditor(text: $primaryConcern)
                                .font(.system(size: 15))
                                .foregroundStyle(CopeColor.text)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 132)
                        }
                        .padding(10)
                        .background(CopeColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(CopeColor.border, lineWidth: 1)
                        )
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Emergency Contact")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CopeColor.text)

                        IntakeTextField(title: "Name", text: $emergencyContactName, contentType: .name)
                        IntakeTextField(title: "Phone", text: $emergencyContactPhone, contentType: .telephoneNumber, keyboardType: .phonePad)
                        IntakeTextField(title: "Relationship", text: $emergencyContactRelationship)
                    }

                    if let errorMessage = session.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(CopeColor.danger)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button {
                        Task {
                            await session.completeIntake(
                                primaryConcern: primaryConcern,
                                emergencyContactName: emergencyContactName,
                                emergencyContactPhone: emergencyContactPhone,
                                emergencyContactRelationship: emergencyContactRelationship
                            )
                        }
                    } label: {
                        Label(session.isLoading ? "Saving Intake" : "Complete Intake", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(session.isLoading ? CopeColor.primaryDark : CopeColor.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(session.isLoading)
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
    }
}

private struct IntakeTextField: View {
    let title: String
    @Binding var text: String
    var contentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(title, text: $text)
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .textFieldStyle(.plain)
            .padding(14)
            .background(CopeColor.surface)
            .foregroundStyle(CopeColor.text)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(CopeColor.border, lineWidth: 1)
            )
    }
}

#Preview {
    OnboardingIntakeView()
        .environmentObject(SessionViewModel())
}
