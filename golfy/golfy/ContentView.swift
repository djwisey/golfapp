import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject var scorecard = Scorecard()
    @State private var course: Course?

    var body: some View {
        TabView {
            NavigationView { StartRoundView() }
                .tabItem { Label("Rounds", systemImage: "list.bullet") }

            if let course {
                NavigationView {
                    HolePagerView(course: course, locationManager: locationManager, scorecard: scorecard)
                        .navigationTitle(course.name)
                }
                .tabItem { Label("GPS", systemImage: "flag") }
            } else {
                Text("Loading course...")
                    .task { await loadCourse() }
                    .tabItem { Label("GPS", systemImage: "flag") }
            }

            NavigationView { ScorecardView(scorecard: scorecard) }
                .tabItem { Label("Scorecard", systemImage: "pencil") }
        }
    }

    private func loadCourse() async {
        if let loaded = try? await CourseService.shared.loadCourse() {
            course = loaded
            scorecard.setupHoles(count: loaded.holes.count)
        }
    }
}

#Preview {
    ContentView()
}
