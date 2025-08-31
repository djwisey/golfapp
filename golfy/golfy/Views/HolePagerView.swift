import SwiftUI
import CoreLocation

private struct HolePage: View {
    let hole: Hole
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var scorecard: Scorecard

    var body: some View {
        VStack(spacing: 16) {
            Text("Hole \(hole.id) - Par \(hole.par)")
                .font(.title2)
            HoleCartoonView(hole: hole)
                .frame(height: 250)
            if let yards = yardages {
                HStack {
                    Text(String(format: "F %.0f yd", yards.front))
                    Text(String(format: "C %.0f yd", yards.center))
                    Text(String(format: "B %.0f yd", yards.back))
                }
            }
            Spacer()
            HStack {
                Button("Add Shot") {}
                Spacer()
                NavigationLink("Scorecard") {
                    ScorecardView(scorecard: scorecard)
                }
                Spacer()
                Button("Move Pin") {}
            }
        }
        .padding()
    }

    private var yardages: (front: Double, center: Double, back: Double)? {
        guard let loc = locationManager.location else { return nil }
        guard let green = hole.green else { return nil }
        return green.yardages(from: loc.coordinate)
    }
}

struct HolePagerView: View {
    let course: Course
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var scorecard: Scorecard
    @State private var index = 0

    var body: some View {
        VStack {
            HolePage(hole: course.holes[index],
                     locationManager: locationManager,
                     scorecard: scorecard)
            HStack {
                Button("Back") { index -= 1 }
                    .disabled(index == 0)
                Spacer()
                Button("Next") { index += 1 }
                    .disabled(index == course.holes.count - 1)
            }
            .padding(.horizontal)
        }
    }
}
