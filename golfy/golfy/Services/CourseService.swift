import Foundation

actor CourseService {
    static let shared = CourseService()
    private let cacheURL: URL

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheURL = caches.appendingPathComponent("course.json")
    }

    func loadCourse(forceReload: Bool = false) async throws -> Course {
        if !forceReload, let data = try? Data(contentsOf: cacheURL) {
            return try JSONDecoder().decode(Course.self, from: data)
        }
        guard let bundleURL = Bundle.main.url(forResource: "course", withExtension: "json") else {
            throw NSError(domain: "CourseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing course.json in bundle"])
        }
        let data = try Data(contentsOf: bundleURL)
        try data.write(to: cacheURL, options: .atomic)
        return try JSONDecoder().decode(Course.self, from: data)
    }
}
