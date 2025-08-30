//
//  golfyApp.swift
//  golfy
//
//  Created by Dylan Wiseman on 30/08/2025.
//

import SwiftUI

@main
struct golfyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
