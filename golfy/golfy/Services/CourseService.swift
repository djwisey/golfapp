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
            // Bounding box around the bundled example course
            let south = 60.165
            let north = 60.171
            let west = -1.227
            let east = -1.215

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

            var components = URLComponents()
            components.queryItems = [URLQueryItem(name: "data", value: query)]

            var request = URLRequest(url: URL(string: "https://overpass-api.de/api/interpreter")!)
            request.httpMethod = "POST"
            request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let (remoteData, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            data = remoteData
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
