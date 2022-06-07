//
//  ddnsApp.swift
//  ddns
//
//  Created by Qiwei Li on 6/7/22.
//

import SwiftUI

@main
struct ddnsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
