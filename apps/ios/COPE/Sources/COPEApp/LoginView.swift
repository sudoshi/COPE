import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("COPE")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(CopeColor.text)

                VStack(alignment: .leading, spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
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

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .textFieldStyle(.plain)
                        .padding(14)
                        .background(CopeColor.surface)
                        .foregroundStyle(CopeColor.text)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(CopeColor.border, lineWidth: 1)
                        )

                    if let errorMessage = session.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(CopeColor.danger)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

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
            .padding(24)
            .frame(maxWidth: 480, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(CopeColor.background)
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionViewModel())
}
