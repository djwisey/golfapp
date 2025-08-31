import SwiftUI

struct ProfileView: View {
    @State private var name = "Golfer"
    @State private var email = "golfer@example.com"
    @State private var handicap = "10"
    @State private var notifications = true

    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                TextField("Handicap", text: $handicap)
                    .keyboardType(.numberPad)
            }
            Section("Settings") {
                Toggle("Notifications", isOn: $notifications)
            }
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationView { ProfileView() }
}
