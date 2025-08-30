import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject var scorecard = Scorecard()
    @State private var course: OverpassResponse?

    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    CourseMapView(locationManager: locationManager, course: $course)
                    if let yards = firstGreenYardages {
                        HStack {
                            Text(String(format: "F %.0f yd", yards.front))
                            Text(String(format: "C %.0f yd", yards.center))
                            Text(String(format: "B %.0f yd", yards.back))
                        }
                        .padding()
                    }
                }
                .navigationTitle("Map")
                .task { await loadCourse() }
                .toolbar { Button("Reload") { Task { await loadCourse(force: true) } } }
            }
            .tabItem { Label("Map", systemImage: "map") }

            NavigationView { TargetsListView(locationManager: locationManager, course: course) }
                .tabItem { Label("Targets", systemImage: "list.bullet") }

            NavigationView { ScorecardView(scorecard: scorecard) }
                .tabItem { Label("Scorecard", systemImage: "pencil") }
        }
    }

    private var firstGreenYardages: (front: Double, center: Double, back: Double)? {
        guard let loc = locationManager.location else { return nil }
        guard let green = course?.elements.first(where: { $0.tags?["golf"] == "green" }) else { return nil }
        return green.yardages(from: loc.coordinate)
    }

    private func loadCourse(force: Bool = false) async {
        if let loaded = try? await OverpassService.shared.loadCourse(forceReload: force) {
            course = loaded
        }
    }
}

#Preview {
    ContentView()
}
