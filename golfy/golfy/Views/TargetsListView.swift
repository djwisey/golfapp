import SwiftUI
import CoreLocation

struct TargetsListView: View {
    @ObservedObject var locationManager: LocationManager
    let hole: Hole

    var body: some View {
        List(targets) { feature in
            HStack {
                Text(feature.type.displayName)
                Spacer()
                if let yards = yardage(to: feature) {
                    Text(String(format: "%.0f yd", yards))
                }
            }
        }
        .navigationTitle("Targets")
    }

    private var targets: [CourseFeature] {
        hole.features.filter { $0.type != .tee && $0.type != .green }
    }

    private func yardage(to feature: CourseFeature) -> Double? {
        guard let user = locationManager.location else { return nil }
        let coord = feature.centroid
        let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return user.distanceYards(to: loc)
    }
}
