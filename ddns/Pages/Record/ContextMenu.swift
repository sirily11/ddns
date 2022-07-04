//
//  ContextMenu.swift
//  ddns
//
//  Created by Qiwei Li on 7/3/22.
//

import SwiftUI

struct ContextMenu: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var cloudflareClient: CloudflareClient
    @EnvironmentObject private var ipModel: IPAddressModel
    @EnvironmentObject private var dnsUpdateModel: DnsUpdateModel
    
    let record: DNSRecord

    
    var body: some View {
        VStack {
            Button(action: { Task { await updateRecord(record: record) } }){
                Text("Update Record to \(ipModel.ipAddress)")
            }
            Button(action: { Task { await deleteRecord(record: record) } }){
                Text("Delete Record from cloudflare")
            }
        }
        .padding()
    }
    
    private func updateRecord(record: DNSRecord) async {
        do {
            record.isUpdating = true
            dnsUpdateModel.update(record: record)
            record.ipAddress = ipModel.ipAddress
            let _ = try await cloudflareClient.use(host: dnsUpdateModel.host!).updateDNSRecord(dns: record)
            record.isUpdating = false
            dnsUpdateModel.update(record: record)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    private func deleteRecord(record: DNSRecord) async {
        do {
            let _ = try await cloudflareClient.deleteDNSRecord(dns: record)
            viewContext.delete(record)
            try viewContext.save()
            dnsUpdateModel.remove(record: record)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}
