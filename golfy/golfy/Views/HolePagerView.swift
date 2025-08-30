import SwiftUI
import CoreLocation

private struct HolePage: View {
    let hole: Hole
    @ObservedObject var locationManager: LocationManager
    @Binding var score: HoleScore

    var body: some View {
        VStack(spacing: 16) {
            Text("Hole \(hole.id) - Par \(hole.par)")
                .font(.title2)
            HoleMapView(locationManager: locationManager, hole: hole)
                .frame(height: 250)
            if let yards = yardages {
                HStack {
                    Text(String(format: "F %.0f yd", yards.front))
                    Text(String(format: "C %.0f yd", yards.center))
                    Text(String(format: "B %.0f yd", yards.back))
                }
            }
            Stepper(value: $score.strokes, in: 0...20) {
                Text("Strokes: \(score.strokes)")
            }
            Stepper(value: $score.putts, in: 0...10) {
                Text("Putts: \(score.putts)")
            }
            NavigationLink("Targets") {
                TargetsListView(locationManager: locationManager, hole: hole)
            }
            Spacer()
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

    var body: some View {
        TabView {
            ForEach(course.holes) { hole in
                HolePage(hole: hole,
                         locationManager: locationManager,
                         score: binding(for: hole.id))
            }
        }
        .tabViewStyle(.page)
    }

    private func binding(for holeID: Int) -> Binding<HoleScore> {
        let index = scorecard.holes.firstIndex { $0.id == holeID }!
        return $scorecard.holes[index]
    }
}
