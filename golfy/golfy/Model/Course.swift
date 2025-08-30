import Foundation
import CoreLocation

struct Coordinate: Codable, Equatable {
    let lat: Double
    let lon: Double
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct CourseFeature: Codable, Identifiable, Equatable {
    enum FeatureType: String, Codable {
        case tee, green, bunker, water, fairway
    }
    let id: Int
    let type: FeatureType
    let points: [Coordinate]

    var centroid: CLLocationCoordinate2D {
        let lat = points.map { $0.lat }.reduce(0, +) / Double(points.count)
        let lon = points.map { $0.lon }.reduce(0, +) / Double(points.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func yardages(from user: CLLocationCoordinate2D) -> (front: Double, center: Double, back: Double)? {
        let userLoc = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let locs = points.map { CLLocation(latitude: $0.lat, longitude: $0.lon) }
        guard !locs.isEmpty else { return nil }
        let centerCoord = centroid
        let center = userLoc.distanceYards(to: CLLocation(latitude: centerCoord.latitude, longitude: centerCoord.longitude))
        let distances = locs.map { userLoc.distanceYards(to: $0) }
        let front = distances.min() ?? center
        let back = distances.max() ?? center
        return (front, center, back)
    }
}

struct Hole: Codable, Identifiable, Equatable {
    let id: Int
    let par: Int
    let features: [CourseFeature]

    var tee: CourseFeature? { features.first(where: { $0.type == .tee }) }
    var green: CourseFeature? { features.first(where: { $0.type == .green }) }
}

struct Course: Codable, Equatable {
    let name: String
    let holes: [Hole]
}

extension CourseFeature.FeatureType {
    var displayName: String {
        switch self {
        case .tee: return "Tee"
        case .green: return "Green"
        case .bunker: return "Bunker"
        case .water: return "Water"
        case .fairway: return "Fairway"
        }
    }
}

extension CLLocation {
    func distanceYards(to other: CLLocation) -> Double {
        distance(from: other) * 1.09361
    }
}
