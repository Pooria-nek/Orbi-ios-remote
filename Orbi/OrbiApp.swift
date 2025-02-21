//
//  OrbiApp.swift
//  Orbi
//
//  Created by Pooria on 1403/12/3.
//

import SwiftUI

@main
struct OrbiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
