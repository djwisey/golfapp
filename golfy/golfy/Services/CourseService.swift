import Foundation
import CoreLocation

private struct OSMResponse: Codable {
    let elements: [OSMElement]
}

private struct OSMElement: Codable {
    let type: String
    let id: Int
    let lat: Double?
    let lon: Double?
    let center: Coordinate?
    let tags: [String: String]?

    var coordinate: Coordinate? {
        if let center { return center }
        if let lat, let lon { return Coordinate(lat: lat, lon: lon) }
        return nil
    }
}

actor CourseService {
    static let shared = CourseService()
    private let cacheURL: URL

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheURL = caches.appendingPathComponent("course.json")
    }

    func loadCourse(forceReload: Bool = false) async throws -> Course {
        let data: Data
        if !forceReload, let cached = try? Data(contentsOf: cacheURL) {
            data = cached
        } else {
            guard let bundleURL = Bundle.main.url(forResource: "course", withExtension: "json") else {
                throw NSError(domain: "CourseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing course.json in bundle"])
            }
            data = try Data(contentsOf: bundleURL)
            try data.write(to: cacheURL, options: .atomic)
        }
        return try decodeOSM(data)
    }

    // MARK: - Remote search

    /// Search for golf courses near a location using the public Overpass API.
    /// - Parameters:
    ///   - location: Center point for the search.
    ///   - radius: Search radius in meters.
    /// - Returns: An array of course summaries discovered within the radius.
    func searchCourses(near location: CLLocationCoordinate2D, radius: Int = 10000) async throws -> [CourseSummary] {
        let query = """
        [out:json];
        node["golf"="course"](around:\(radius),\(location.latitude),\(location.longitude));
        out center;
        """

        let url = URL(string: "https://overpass-api.de/api/interpreter")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "data=\(query)".data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OSMResponse.self, from: data)

        return response.elements.compactMap { element in
            guard let coord = element.coordinate else { return nil }
            let name = element.tags?["name"] ?? "Course \(element.id)"
            return CourseSummary(id: element.id, name: name, coordinate: coord)
        }
    }

    private func decodeOSM(_ data: Data) throws -> Course {
        let response = try JSONDecoder().decode(OSMResponse.self, from: data)
        let tees = response.elements.filter { $0.tags?["golf"] == "tee" }
        let greens = response.elements.filter { $0.tags?["golf"] == "green" }
        let count = min(tees.count, greens.count)
        var holes: [Hole] = []
        for i in 0..<count {
            guard let teeCoord = tees[i].coordinate,
                  let greenCoord = greens[i].coordinate else { continue }
            let teeFeature = CourseFeature(id: tees[i].id, type: .tee, points: [teeCoord])
            let greenFeature = CourseFeature(id: greens[i].id, type: .green, points: [greenCoord])
            holes.append(Hole(id: i + 1, par: 4, features: [teeFeature, greenFeature]))
        }
        return Course(name: "OSM Course", holes: holes)
    }
}
