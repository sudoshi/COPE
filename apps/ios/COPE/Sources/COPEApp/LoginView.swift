import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            CopeColor.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("COPE")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(CopeColor.text)

                VStack(spacing: 12) {
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
                }

                Button(action: {}) {
                    Text("Sign In")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(CopeColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(24)
        }
    }
}

#Preview {
    LoginView()
}
