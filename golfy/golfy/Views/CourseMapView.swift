import SwiftUI
import MapKit

/// Displays a hybrid map showing the user's location and green pins.
/// The map is constrained to the bounds of the loaded course using
/// `MKMapView`'s camera boundary APIs so the user cannot pan away from
/// the course area.
struct CourseMapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    @Binding var course: OverpassResponse?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.mapType = .hybrid
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove old annotations except for the user location
        let nonUserAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(nonUserAnnotations)

        // Add a pin for each green
        if let greens = course?.elements.filter({ $0.tags?["golf"] == "green" }) {
            for element in greens {
                guard let coord = element.centroid ?? element.coordinate else { continue }
                let pin = MKPointAnnotation()
                pin.title = "Green"
                pin.coordinate = coord
                mapView.addAnnotation(pin)
            }
        }

        // Center the map on the course and restrict the camera to its bounds
        if let region = courseRegion(course) {
            mapView.setRegion(region, animated: true)
            let boundary = MKMapCameraBoundary(coordinateRegion: region)
            mapView.setCameraBoundary(boundary, animated: false)
        }
    }

    // Calculates bounding region for the entire course
    private func courseRegion(_ course: OverpassResponse?) -> MKCoordinateRegion? {
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

