import SwiftUI
import MapKit

/// Displays hybrid map showing user location and green pins
struct CourseMapView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var course: OverpassResponse?
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.155, longitude: -1.145), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: greenTargets) { target in
            MapMarker(coordinate: target.centroid ?? target.coordinate!)
        }
        .mapStyle(.hybrid)
        .onChange(of: locationManager.location) { loc in
            if let loc { region.center = loc.coordinate }
        }
    }

    private var greenTargets: [OverpassElement] {
        course?.elements.filter { $0.tags?["golf"] == "green" } ?? []
    }
}
