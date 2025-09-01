import Foundation
import CoreLocation

struct CourseSummary: Identifiable, Equatable {
    let id: Int
    let name: String
    let coordinate: Coordinate
}

