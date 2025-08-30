import Foundation

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
