import Foundation

/// Service responsible for loading and caching Overpass OpenStreetMap golf data
actor OverpassService {
    static let shared = OverpassService()
    private let cacheURL: URL

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheURL = caches.appendingPathComponent("shetland_golf.json")
    }

    /// Loads course data either from cache or network
    func loadCourse(forceReload: Bool = false) async throws -> OverpassResponse {
        if !forceReload, let data = try? Data(contentsOf: cacheURL) {
            return try JSONDecoder().decode(OverpassResponse.self, from: data)
        }
        let query = """
        [out:json][timeout:25];
        area["name"="Shetland Islands"]->.searchArea;
        (
          node["golf"="tee"](area.searchArea);
          node["golf"="green"](area.searchArea);
          node["golf"="bunker"](area.searchArea);
          way["golf"="fairway"](area.searchArea);
          way["natural"="water"]["golf"="water_hazard"](area.searchArea);
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
