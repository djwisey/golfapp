import SwiftUI

struct HoleCartoonView: View {
    let hole: Hole

    var body: some View {
        GeometryReader { geo in
            if let tee = hole.tee?.points.first, let green = hole.green?.points.first {
                let minLat = min(tee.lat, green.lat)
                let maxLat = max(tee.lat, green.lat)
                let minLon = min(tee.lon, green.lon)
                let maxLon = max(tee.lon, green.lon)
                let scaleX = geo.size.width / CGFloat(maxLon - minLon)
                let scaleY = geo.size.height / CGFloat(maxLat - minLat)

                let teePoint = CGPoint(x: CGFloat(tee.lon - minLon) * scaleX,
                                       y: geo.size.height - CGFloat(tee.lat - minLat) * scaleY)
                let greenPoint = CGPoint(x: CGFloat(green.lon - minLon) * scaleX,
                                         y: geo.size.height - CGFloat(green.lat - minLat) * scaleY)

                Path { path in
                    path.move(to: teePoint)
                    path.addLine(to: greenPoint)
                }
                .stroke(Color.brown, lineWidth: 4)

                Circle()
                    .fill(Color.blue)
                    .frame(width: 16, height: 16)
                    .position(teePoint)

                Circle()
                    .fill(Color.green)
                    .frame(width: 24, height: 24)
                    .position(greenPoint)
            }
        }
    }
}

#Preview {
    HoleCartoonView(hole: Course(name: "", holes: [Hole(id: 1, par: 4, features: [
        CourseFeature(id: 1, type: .tee, points: [Coordinate(lat: 0, lon: 0)]),
        CourseFeature(id: 2, type: .green, points: [Coordinate(lat: 1, lon: 1)])
    ])]).holes[0])
}
