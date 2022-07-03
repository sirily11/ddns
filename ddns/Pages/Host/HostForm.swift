//
//  HostForm.swift
//  ddns
//
//  Created by Qiwei Li on 6/7/22.
//

import SwiftUI

struct HostForm: View {
    let host: Host? = nil
    @State var apiKey: String = ""
    @State var zoneId: String = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cloudflareClient: CloudflareClient
    
    let onClose: () -> ()
    
    var body: some View {
        VStack {
            Text("Add a host")
                .font(.headline)
            Form{
                Divider()
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Zone ID", text: $zoneId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                
                Divider()
            }
            HStack{
                Button(action: { onClose() }){
                    Text("Close")
                }
                Button(action: { Task { await save() } }){
                    Text("Save")
                }
            }
        }
        .padding(.all)
        .frame(width: 500)
        .onAppear{
            if host != nil{
                apiKey = host!.apiKey!
            }
    }
    
}

    private func save() async {
        let newHost = Host(context: viewContext)
        newHost.apiKey = apiKey
        newHost.zoneId = zoneId
        do{
            let records = try? await cloudflareClient.use(host: newHost).listDNSRecords()
            if let records = records {
                let dnsRecords: [DNSRecord] = records.result.map { result in
                    result.toDnsRecord(context: viewContext)
                }
                newHost.addToRecords(NSSet(array: dnsRecords))
            }
            try viewContext.save()
            onClose()
        } catch{
            print("Save failed")
        }
        
    }
}

struct HostForm_Previews: PreviewProvider {
    static var previews: some View {
        HostForm(onClose: {})
    }
}
