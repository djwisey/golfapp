import SwiftUI
import CoreLocation

struct CourseListView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var search = ""
    @State private var courses: [CourseSummary] = []

    var body: some View {
        List {
            ForEach(filter(courses)) { item in
                CourseRow(item: item)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Course")
        .searchable(text: $search)
        .task {
            await loadCourses()
        }
    }

    private func loadCourses() async {
        guard let location = locationManager.location?.coordinate else { return }
        do {
            courses = try await CourseService.shared.searchCourses(near: location)
        } catch {
            print("Failed to fetch courses: \(error)")
        }
    }

    private func filter(_ items: [CourseSummary]) -> [CourseSummary] {
        if search.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }
}

struct CourseRow: View {
    let item: CourseSummary
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

