import SwiftUI

struct CredentialsSheet: View {
    @State private var username: String = ""
    @State private var password: String = ""
    var onSave: (Credentials) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Text("Enter Gateway Credentials")
                .font(.headline)
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Save") {
                    onSave(Credentials(username: username, password: password))
                    dismiss()
                }
            }
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    CredentialsSheet(onSave: { _ in })
}
