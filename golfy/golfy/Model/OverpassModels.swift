import Foundation
import CoreLocation

/// Geometry point used by Overpass API for ways and relations
struct GeometryPoint: Codable, Equatable {
    let lat: Double
    let lon: Double
}

/// Element returned from the Overpass API. Elements can be nodes or ways.
struct OverpassElement: Codable, Identifiable, Equatable {
    let id: Int
    let type: String
    let lat: Double?
    let lon: Double?
    let tags: [String: String]?
    let geometry: [GeometryPoint]?

    /// Convenience coordinate for elements that have a single point location
    var coordinate: CLLocationCoordinate2D? {
        if let lat, let lon { return CLLocationCoordinate2D(latitude: lat, longitude: lon) }
        return nil
    }

    /// Calculates the centroid for polygon geometry
    var centroid: CLLocationCoordinate2D? {
        guard let geometry, !geometry.isEmpty else { return coordinate }
        let lat = geometry.map { $0.lat }.reduce(0,+) / Double(geometry.count)
        let lon = geometry.map { $0.lon }.reduce(0,+) / Double(geometry.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    /// Calculates front/center/back yardages from a user location
    func yardages(from user: CLLocationCoordinate2D) -> (front: Double, center: Double, back: Double)? {
        let userLoc = CLLocation(latitude: user.latitude, longitude: user.longitude)
        guard let points = geometry?.map({ CLLocation(latitude: $0.lat, longitude: $0.lon) }) ?? (coordinate.map { [CLLocation(latitude: $0.latitude, longitude: $0.longitude)] }) else { return nil }
        guard !points.isEmpty else { return nil }
        let centerCoord = centroid!
        let center = userLoc.distanceYards(to: CLLocation(latitude: centerCoord.latitude, longitude: centerCoord.longitude))
        let distances = points.map { userLoc.distanceYards(to: $0) }
        let front = distances.min() ?? center
        let back = distances.max() ?? center
        return (front, center, back)
    }
}

struct OverpassResponse: Codable, Equatable {
    let elements: [OverpassElement]
}

extension CLLocation {
    /// Returns distance to another location converted to yards
    func distanceYards(to other: CLLocation) -> Double {
        distance(from: other) * 1.09361
    }
}
