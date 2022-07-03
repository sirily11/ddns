//
//  RecordForm.swift
//  ddns
//
//  Created by Qiwei Li on 6/7/22.
//

import SwiftUI

struct RecordForm: View {
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var hosts: FetchedResults<Host>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var ipModel: IPAddressModel
    @EnvironmentObject var cloudflareClient: CloudflareClient
    
    let host: Host
    let onClose: () -> ()
    let onSave: (DNSRecord) -> ()
    
    @State var name: String = ""
    @State var type: String = ""
    @State var watch: Bool = false
    @State var error: Error?
    @State var showError = false
    @State var isLoading = false
    
    var body: some View {
        Form{
            HStack{
                Text("Add DNS Record").font(.headline)
                if let error = error {
                    Image(systemSymbol: .infoCircleFill)
                        .onTapGesture {
                            showError = true
                        }
                        .foregroundColor(.red)
                        .popover(isPresented: $showError){
                            Text("\(error.localizedDescription)")
                                .padding()
                        }
                }
            }
            Divider()
            HStack{
                TextField("Name", text: $name)
                Text(".\(host.domainName!)")
            }
            Picker("DNS Record Type", selection: $type){
                ForEach(DNSRecordType.allCases, id: \.rawValue){ type in
                    Text(type.rawValue).tag(type.rawValue)
                }
            }
            Toggle("Watch", isOn: $watch).toggleStyle(.checkbox)
            
            HStack{
                Button(action: { onClose() }){
                    Text("Close")
                }
                
                Button(action: { Task { if !isLoading{ await save() } }  }){
                    if isLoading {
                        Text("Saving...")
                    } else {
                        Text("Save")
                    }
                }
            }
            
        }
        .padding()
        .frame(width: 400, alignment: .leading)
    }
    
    
    private func save() async {
        isLoading = true
        let record = DNSRecord(context: viewContext)
        record.name = name
        record.watch = watch
        record.type = type
        record.ipAddress = ipModel.ipAddress
        record.host = host
        record.timestamp = Date()
        
        do{
            let cloudflareResult = try await cloudflareClient.use(host: host).createDNSRecord(dns: record)
            print(cloudflareResult)
            record.cloudflareId = cloudflareResult.result?.id
            try viewContext.save()
            onSave(record)
        } catch let error{
            self.error = error
            print("Cannot save model due to \(error.localizedDescription)")
        }
        isLoading = false
    }
}
