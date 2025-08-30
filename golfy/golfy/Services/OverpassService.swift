import Foundation
import CoreLocation

/// Service responsible for loading and caching Overpass OpenStreetMap golf data
actor OverpassService {
    static let shared = OverpassService()
    private let cacheURL: URL

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheURL = caches.appendingPathComponent("course.json")
    }

    /// Loads course data for a bounding box around the given coordinate.
    /// - Parameters:
    ///   - center: Center coordinate of the golf course.
    ///   - span: Half-size of the bounding box in degrees. Defaults to ~0.02º (~2km).
    ///   - forceReload: When true, ignore any cached data.
    func loadCourse(around center: CLLocationCoordinate2D, span: CLLocationDegrees = 0.02, forceReload: Bool = false) async throws -> OverpassResponse {
        if !forceReload, let data = try? Data(contentsOf: cacheURL) {
            return try JSONDecoder().decode(OverpassResponse.self, from: data)
        }

        let south = center.latitude - span
        let north = center.latitude + span
        let west  = center.longitude - span
        let east  = center.longitude + span

        let query = """
        [out:json][timeout:25];
        (
          node["golf"="tee"](\(south),\(west),\(north),\(east));
          node["golf"="green"](\(south),\(west),\(north),\(east));
          node["golf"="bunker"](\(south),\(west),\(north),\(east));
          way["golf"="fairway"](\(south),\(west),\(north),\(east));
          way["natural"="water"]["golf"="water_hazard"](\(south),\(west),\(north),\(east));
        );
        out body;
        >;
        out skel qt;
        """

        let urlString = "https://overpass-api.de/api/interpreter?data=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        let url = URL(string: urlString)!
        let (data, _) = try await URLSession.shared.data(from: url)
        try data.write(to: cacheURL, options: .atomic)
        return try JSONDecoder().decode(OverpassResponse.self, from: data)
    }
}
