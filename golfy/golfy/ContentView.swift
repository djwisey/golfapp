import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject var scorecard = Scorecard()
    @State private var course: Course?
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        TabView {
            NavigationView { StartRoundView() }
                .tabItem { Label("Home", systemImage: "house") }

            NavigationView { CourseListView(locationManager: locationManager) }
                .tabItem { Label("Courses", systemImage: "mappin.circle") }

            if let course {
                NavigationView {
                    HolePagerView(course: course, locationManager: locationManager, scorecard: scorecard)
                        .navigationTitle(course.name)
                }
                .tabItem { Label("GPS", systemImage: "flag") }
            } else if isLoading {
                ProgressView("Loading course...")
                    .tabItem { Label("GPS", systemImage: "flag") }
            } else {
                Text("Failed to load course")
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
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func loadCourse() async {
        isLoading = true
        showError = false
        do {
            let loaded = try await CourseService.shared.loadCourse()
            course = loaded
            scorecard.setupHoles(count: loaded.holes.count)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
}

#Preview {
    ContentView()
}
