import SwiftUI

private struct NumberPad: View {
    let onInput: (Int?) -> Void

    private let rows = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
        ["", "0", "del"]
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { item in
                        if item.isEmpty {
                            Color.clear.frame(width: 60, height: 60)
                        } else {
                            Button {
                                if item == "del" {
                                    onInput(nil)
                                } else if let num = Int(item) {
                                    onInput(num)
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                    if item == "del" {
                                        Image(systemName: "delete.left")
                                    } else {
                                        Text(item)
                                    }
                                }
                                .frame(width: 60, height: 60)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

private struct HolePageView: View {
    @Binding var hole: HoleScore
    @State private var entry = ""

    var body: some View {
        VStack(spacing: 32) {
            Text("Hole \(hole.id)")
                .font(.title)
            Text(entry.isEmpty ? "0" : entry)
                .font(.system(size: 64, weight: .bold))

            NumberPad { value in
                if let num = value {
                    entry.append(String(num))
                } else if !entry.isEmpty {
                    entry.removeLast()
                }
                hole.strokes = Int(entry) ?? 0
            }

            Spacer()
        }
        .padding()
    }
}

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
