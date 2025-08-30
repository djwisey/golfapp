import Foundation

struct HoleScore: Identifiable, Codable {
    let id: Int
    var strokes: Int
    var putts: Int
}

/// Stores scorecard information to disk using Codable JSON
class Scorecard: ObservableObject {
    @Published var holes: [HoleScore]
    private let fileURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("scorecard.json")
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode([HoleScore].self, from: data) {
            holes = decoded
        } else {
            holes = (1...18).map { HoleScore(id: $0, strokes: 0, putts: 0) }
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(holes) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    var totalStrokes: Int { holes.map { $0.strokes }.reduce(0,+) }
    var totalPutts: Int { holes.map { $0.putts }.reduce(0,+) }
}
