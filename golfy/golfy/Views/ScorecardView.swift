import SwiftUI

/// Simple scorecard allowing strokes and putts per hole and showing totals
struct ScorecardView: View {
    @ObservedObject var scorecard: Scorecard

    var body: some View {
        List {
            ForEach($scorecard.holes) { $hole in
                HStack {
                    Text("Hole \(hole.id)")
                    Spacer()
                    Stepper(value: $hole.strokes, in: 0...20) { Text("Strokes: \(hole.strokes)") }
                    Stepper(value: $hole.putts, in: 0...10) { Text("Putts: \(hole.putts)") }
                }
            }
            HStack {
                Text("Totals")
                Spacer()
                Text("Strokes: \(scorecard.totalStrokes)")
                Text("Putts: \(scorecard.totalPutts)")
            }
        }
        .navigationTitle("Scorecard")
        .toolbar { Button("Save") { scorecard.save() } }
    }
}
