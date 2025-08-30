import SwiftUI
import CoreLocation

/// Lists targets (tees, greens, bunkers, water, fairways) with live yardages
struct TargetsListView: View {
    @ObservedObject var locationManager: LocationManager
    var course: OverpassResponse?

    var body: some View {
        List(targets) { element in
            HStack {
                Text(element.tags?["golf"] ?? element.tags?["natural"] ?? "Target")
                Spacer()
                if let yards = yardage(to: element) {
                    Text(String(format: "%.0f yd", yards))
                }
            }
        }
        .navigationTitle("Targets")
    }

    private var targets: [OverpassElement] {
        course?.elements.filter { element in
            guard let tag = element.tags?["golf"] ?? element.tags?["natural"] else { return false }
            return ["tee", "green", "bunker", "fairway", "water", "water_hazard"].contains(tag)
        } ?? []
    }

    private func yardage(to element: OverpassElement) -> Double? {
        guard let user = locationManager.location else { return nil }
        guard let coord = element.centroid else { return nil }
        let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return user.distanceYards(to: loc)
    }
}
