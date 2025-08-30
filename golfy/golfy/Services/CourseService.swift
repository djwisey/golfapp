import Foundation

actor CourseService {
    static let shared = CourseService()
    private let endpoint = URL(string: "http://localhost:3000/courses/shetland")!

    func loadCourse(forceReload: Bool = false) async throws -> Course {
        let (data, _) = try await URLSession.shared.data(from: endpoint)
        return try JSONDecoder().decode(Course.self, from: data)
    }
}
