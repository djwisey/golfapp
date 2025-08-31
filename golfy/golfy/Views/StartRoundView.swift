import SwiftUI

struct StartRoundView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("START ROUND")
                    .font(.title)
                    .bold()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Round")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("18 Hol")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("77")
                            .font(.system(size: 48, weight: .bold))
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        Label("72°", systemImage: "sun.max")
                        Label("5 mph", systemImage: "wind")
                    }
                }
            }

            NavigationLink("Start Round") {
                CourseListView()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationView { StartRoundView() }
}
