import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionViewModel
    @State private var mode: AuthenticationMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var inviteToken = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: .now) ?? .now
    @State private var confirmPassword = ""
    @State private var acceptedRegistrationConsentTypes: Set<PatientConsentType> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("COPE")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(CopeColor.text)

                Picker("Authentication", selection: $mode) {
                    ForEach(AuthenticationMode.allCases) { mode in
                        Label(mode.title, systemImage: mode.systemImage)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                if mode == .signIn {
                    signInForm
                } else {
                    registrationForm
                }

                if let errorMessage = session.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(CopeColor.danger)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
            .frame(maxWidth: 520, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(CopeColor.background)
        .onAppear(perform: applyPendingInviteToken)
        .onChange(of: session.pendingInviteToken) {
            applyPendingInviteToken()
        }
        .sheet(
            isPresented: Binding(
                get: { session.pendingMFAToken != nil },
                set: { isPresented in
                    if !isPresented {
                        session.cancelMFA()
                    }
                }
            )
        ) {
            MFAVerificationView()
                .environmentObject(session)
                .presentationDetents([.medium])
        }
    }

    private var signInForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            AuthTextField(
                title: "Email",
                text: $email,
                contentType: .emailAddress,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            AuthSecureField(title: "Password", text: $password, contentType: .password)

            Button {
                Task {
                    await session.signIn(email: email, password: password)
                }
            } label: {
                Label(session.isLoading ? "Signing In" : "Sign In", systemImage: "arrow.right.circle.fill")
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
    }

    private var registrationForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            AuthTextField(
                title: "Invite Code",
                text: $inviteToken,
                contentType: .oneTimeCode,
                keyboardType: .default,
                autocapitalization: .never
            )

            HStack(spacing: 12) {
                AuthTextField(title: "First Name", text: $firstName, contentType: .givenName)
                AuthTextField(title: "Last Name", text: $lastName, contentType: .familyName)
            }

            AuthTextField(
                title: "Email",
                text: $email,
                contentType: .emailAddress,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(CopeColor.text)
                .padding(14)
                .background(CopeColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(CopeColor.border, lineWidth: 1)
                )

            AuthSecureField(title: "Password", text: $password, contentType: .newPassword)
            AuthSecureField(title: "Confirm Password", text: $confirmPassword, contentType: .newPassword)

            VStack(spacing: 12) {
                ForEach(PatientConsentType.requiredOnboardingConsents) { type in
                    ConsentAcceptanceRow(
                        type: type,
                        isOn: Binding(
                            get: { acceptedRegistrationConsentTypes.contains(type) },
                            set: { isAccepted in
                                if isAccepted {
                                    acceptedRegistrationConsentTypes.insert(type)
                                } else {
                                    acceptedRegistrationConsentTypes.remove(type)
                                }
                            }
                        )
                    )
                }
            }

            Button {
                submitRegistration()
            } label: {
                Label(session.isLoading ? "Creating Account" : "Create Account", systemImage: "person.badge.plus.fill")
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
    }

    private func submitRegistration() {
        guard Set(PatientConsentType.requiredOnboardingConsents).isSubset(of: acceptedRegistrationConsentTypes) else {
            session.errorMessage = "Accept the required consent items to create your account."
            return
        }

        guard password == confirmPassword else {
            session.errorMessage = "Passwords must match."
            return
        }

        Task {
            await session.register(
                PatientRegistration(
                    inviteToken: inviteToken,
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    dateOfBirth: Self.birthDateFormatter.string(from: dateOfBirth),
                    timezone: TimeZone.current.identifier
                )
            )
        }
    }

    private func applyPendingInviteToken() {
        guard let pendingInviteToken = session.pendingInviteToken else {
            return
        }

        inviteToken = pendingInviteToken
        mode = .register
    }

    private static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

private enum AuthenticationMode: String, CaseIterable, Identifiable {
    case signIn
    case register

    var id: String { rawValue }

    var title: String {
        switch self {
        case .signIn:
            return "Sign In"
        case .register:
            return "Register"
        }
    }

    var systemImage: String {
        switch self {
        case .signIn:
            return "person.crop.circle"
        case .register:
            return "person.badge.plus"
        }
    }
}

private struct MFAVerificationView: View {
    @EnvironmentObject private var session: SessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                AuthTextField(
                    title: "Verification Code",
                    text: $code,
                    contentType: .oneTimeCode,
                    keyboardType: .numberPad,
                    autocapitalization: .never
                )

                if let errorMessage = session.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(CopeColor.danger)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    Task {
                        await session.verifyMFA(code: code)
                        if session.pendingMFAToken == nil {
                            dismiss()
                        }
                    }
                } label: {
                    Label(session.isLoading ? "Verifying" : "Verify", systemImage: "checkmark.shield.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(session.isLoading ? CopeColor.primaryDark : CopeColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(session.isLoading)

                Button(role: .cancel) {
                    session.cancelMFA()
                    dismiss()
                } label: {
                    Label("Use Different Account", systemImage: "arrow.uturn.backward.circle")
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
            }
            .padding(24)
            .background(CopeColor.background)
            .navigationTitle("Verification")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationBackground(CopeColor.background)
    }
}

private struct AuthTextField: View {
    let title: String
    @Binding var text: String
    var contentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words

    var body: some View {
        TextField(title, text: $text)
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization)
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

private struct AuthSecureField: View {
    let title: String
    @Binding var text: String
    var contentType: UITextContentType?

    var body: some View {
        SecureField(title, text: $text)
            .textContentType(contentType)
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
    LoginView()
        .environmentObject(SessionViewModel())
}
