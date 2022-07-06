//
//  ContentView.swift
//  ddns
//
//  Created by Qiwei Li on 6/7/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var model: IPAddressModel
    @EnvironmentObject var dnsUpdateModel: DnsUpdateModel
    @EnvironmentObject var cloudflareClient: CloudflareClient
    
    let ipTimer = Timer.publish(every: 1800, on: .main, in: .common).autoconnect()

    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var hosts: FetchedResults<Host>

    var body: some View {
        NavigationView {
            HostList(hosts: hosts)
        }
        .onReceive(ipTimer){ time in
            Task{
                await updateRecords()
            }
        }
        .navigationTitle(dnsUpdateModel.getTitle(title: "Home"))
        .task {
           await updateRecords()
        }
    }
    
    func updateRecords() async {
        do {
            print("Updating...")
            await model.update()
            let fetchRequest = NSFetchRequest<Host>(entityName: "Host")
            let foundHosts = try viewContext.fetch(fetchRequest)
            try await dnsUpdateModel.update(hosts: foundHosts, ip: model.ipAddress)
            
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}
