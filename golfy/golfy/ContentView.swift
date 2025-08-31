import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject var scorecard = Scorecard()
    @State private var course: Course?

    var body: some View {
        TabView {
            NavigationView { StartRoundView() }
                .tabItem { Label("Home", systemImage: "house") }

            NavigationView { CourseListView() }
                .tabItem { Label("Courses", systemImage: "mappin.circle") }

            if let course {
                NavigationView {
                    HolePagerView(course: course, locationManager: locationManager, scorecard: scorecard)
                        .navigationTitle(course.name)
                }
                .tabItem { Label("GPS", systemImage: "flag") }
            } else {
                ProgressView("Loading course...")
                    .tabItem { Label("GPS", systemImage: "flag") }
            }

            NavigationView { HistoryView() }
                .tabItem { Label("History", systemImage: "clock") }

            NavigationView { ProfileView() }
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .task {
            if course == nil {
                await loadCourse()
            }
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
