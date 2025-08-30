import SwiftUI
import MapKit

/// Displays hybrid map showing user location and green pins
struct CourseMapView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var course: OverpassResponse?
    @State private var position: MapCameraPosition = .userLocation(followsHeading: false)
    @State private var bounds: MapCameraBounds?

    var body: some View {
        Map(position: $position, bounds: bounds) {
            UserAnnotation()
            ForEach(greenTargets) { target in
                Marker("Green", coordinate: target.centroid ?? target.coordinate!)
            }
        }
        .mapStyle(.hybrid)
        .onChange(of: course) { _, _ in
            if let region = courseRegion {
                bounds = MapCameraBounds(centerCoordinateBounds: region)
                position = .region(region)
            }
        }
    }

    private var greenTargets: [OverpassElement] {
        course?.elements.filter { $0.tags?["golf"] == "green" } ?? []
    }

    /// Calculates bounding region for the entire course
    private var courseRegion: MKCoordinateRegion? {
        let coords = course?.elements.compactMap { $0.coordinate ?? $0.centroid }
        guard let minLat = coords?.map({ $0.latitude }).min(),
              let maxLat = coords?.map({ $0.latitude }).max(),
              let minLon = coords?.map({ $0.longitude }).min(),
              let maxLon = coords?.map({ $0.longitude }).max() else { return nil }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.2,
                                    longitudeDelta: (maxLon - minLon) * 1.2)
        return MKCoordinateRegion(center: center, span: span)
    }
}
