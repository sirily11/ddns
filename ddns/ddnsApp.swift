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
    @StateObject var ipModel = IPAddressModel()
    @StateObject var cloudflareClient = CloudflareClient()
    @State var dnsUpdateModdel = DnsUpdateModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(ipModel)
                .environmentObject(cloudflareClient)
                .environmentObject(dnsUpdateModdel)
        }
    }
}
