//
//  ContextMenu.swift
//  ddns
//
//  Created by Qiwei Li on 7/3/22.
//

import SwiftUI

struct RecordItemContextMenu: View {
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
        await dnsUpdateModel.updateDnsRecord(context: viewContext, record: record, ip: ipModel.ipAddress)
    }
    
    private func deleteRecord(record: DNSRecord) async {
        await dnsUpdateModel.deleteDnsRecord(context: viewContext, record: record)
    }
}
