import SwiftUI

/// View for editing a single hole's score
private struct HolePageView: View {
    @Binding var hole: HoleScore

    var body: some View {
        VStack(spacing: 16) {
            Text("Hole \(hole.id)")
                .font(.title)
            Stepper(value: $hole.strokes, in: 0...20) {
                Text("Strokes: \(hole.strokes)")
            }
            Stepper(value: $hole.putts, in: 0...10) {
                Text("Putts: \(hole.putts)")
            }
            Spacer()
        }
        .padding()
    }
}

/// Simple scorecard allowing strokes and putts per hole with swipeable pages
struct ScorecardView: View {
    @ObservedObject var scorecard: Scorecard

    var body: some View {
        TabView {
            ForEach($scorecard.holes) { $hole in
                HolePageView(hole: $hole)
            }
            VStack(spacing: 8) {
                Text("Totals")
                    .font(.title2)
                Text("Strokes: \(scorecard.totalStrokes)")
                Text("Putts: \(scorecard.totalPutts)")
                Spacer()
            }
            .padding()
        }
        .tabViewStyle(.page)
        .navigationTitle("Scorecard")
        .toolbar { Button("Save") { scorecard.save() } }
    }
}
