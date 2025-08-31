import SwiftUI

struct PastRound: Identifiable {
    let id = UUID()
    let date: Date
    let course: String
    let score: Int
}

struct HistoryView: View {
    private let rounds: [PastRound] = [
        PastRound(date: Date().addingTimeInterval(-86400 * 2), course: "Links at St Andrews", score: 72),
        PastRound(date: Date().addingTimeInterval(-86400 * 30), course: "Pebble Beach", score: 80),
    ]

    var body: some View {
        List {
            ForEach(groupedRounds.keys.sorted(by: >), id: \.self) { month in
                Section(monthFormatter.string(from: month)) {
                    ForEach(groupedRounds[month]!) { round in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(dateFormatter.string(from: round.date))
                                    .font(.subheadline)
                                Text(round.course)
                            }
                            Spacer()
                            Text("\(round.score)")
                                .foregroundStyle(round.score <= 72 ? Color.green : Color.red)
                        }
                    }
                }
            }
        }
        .navigationTitle("Past Rounds")
    }

    private var groupedRounds: [Date: [PastRound]] {
        Dictionary(grouping: rounds) { round in
            let comps = Calendar.current.dateComponents([.year, .month], from: round.date)
            return Calendar.current.date(from: comps) ?? round.date
        }
    }

    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy"
        return df
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
}

#Preview {
    NavigationView { HistoryView() }
}
