import SwiftUI
import MapKit

struct HoleMapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    let hole: Hole

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.mapType = .hybrid
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let nonUser = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(nonUser)

        if let green = hole.green {
            let pin = MKPointAnnotation()
            pin.title = "Green"
            pin.coordinate = green.centroid
            mapView.addAnnotation(pin)
        }

        if let tee = hole.tee {
            let pin = MKPointAnnotation()
            pin.title = "Tee"
            pin.coordinate = tee.centroid
            mapView.addAnnotation(pin)
        }

        let coords = hole.features.flatMap { $0.points.map { $0.clCoordinate } }
        guard let minLat = coords.map({ $0.latitude }).min(),
              let maxLat = coords.map({ $0.latitude }).max(),
              let minLon = coords.map({ $0.longitude }).min(),
              let maxLon = coords.map({ $0.longitude }).max() else { return }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5,
                                    longitudeDelta: (maxLon - minLon) * 1.5)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
        mapView.setCameraBoundary(MKMapCameraBoundary(coordinateRegion: region), animated: false)
    }
}
