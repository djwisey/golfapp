import SwiftUI
import Combine

struct CourseListItem: Identifiable {
    let id = UUID()
    let name: String
}

struct CourseListView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var search = ""
    @State private var nearby: [CourseListItem] = []
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
        .onReceive(locationManager.$location
            .compactMap { $0 }
            .debounce(for: .seconds(1), scheduler: RunLoop.main)) { _ in
                Task { await loadCourses() }
            }
    }

    private func filter(_ items: [CourseListItem]) -> [CourseListItem] {
        if search.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    @MainActor
    private func loadCourses() async {
        // Placeholder implementation: load static courses.
        // Replace with API call using locationManager.location if needed.
        nearby = [
            .init(name: "Green Valley Golf Club"),
            .init(name: "River Ridge Golf Club")
        ]
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
    NavigationView { CourseListView(locationManager: LocationManager()) }
}
