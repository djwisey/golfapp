import SwiftUI

struct CourseListItem: Identifiable {
    let id = UUID()
    let name: String
}

struct CourseListView: View {
    @State private var search = ""
    private let nearby: [CourseListItem] = [
        .init(name: "Green Valley Golf Club"),
        .init(name: "River Ridge Golf Club"),
    ]
    private let recent: [CourseListItem] = [
        .init(name: "Sunvalley Golf Course"),
    ]

    var body: some View {
        List {
            Section("Nearby") {
                ForEach(filter(nearby)) { item in
                    CourseRow(item: item)
                }
            }
            Section("Recent") {
                ForEach(filter(recent)) { item in
                    CourseRow(item: item)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Course")
        .searchable(text: $search)
    }

    private func filter(_ items: [CourseListItem]) -> [CourseListItem] {
        if search.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }
}

struct CourseRow: View {
    let item: CourseListItem
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .frame(width: 60, height: 60)
            Text(item.name)
            Spacer()
        }
    }
}

#Preview {
    NavigationView { CourseListView() }
}
