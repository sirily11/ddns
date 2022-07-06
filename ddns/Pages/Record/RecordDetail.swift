//
//  HostDetail.swift
//  ddns
//
//  Created by Qiwei Li on 6/7/22.
//

import SwiftUI
import SFSafeSymbols

struct Person: Identifiable {
    let name: String
    let id = UUID()
}

struct RecordDetail: View {
    let host: Host
    @EnvironmentObject var ipModel: IPAddressModel
    @EnvironmentObject var cloudflareClient: CloudflareClient
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dnsUpdateModel: DnsUpdateModel
    
    @State var showAddRecord = false
    @State var selectedRecord = Set<DNSRecord.ID>()
    @State var sortOrder: [KeyPathComparator<DNSRecord>] = [
        .init(\.name, order: SortOrder.forward)
        ]
    
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                CardView{
                    Text("API Key: \(host.apiKey ?? "")")
                        .frame(height: 100)
                }
                CardView{
                    Text("Current IP Address: \(ipModel.ipAddress)")
                        .frame(height: 100)
                }
                CardView{
                    Text("ZoneID: \(host.zoneId!)")
                        .frame(height: 100)
                }
            }
            Spacer()
            
            Table(dnsUpdateModel.records, selection: $selectedRecord, sortOrder: $sortOrder){
                TableColumn("Type"){record in
                    Text(record.type!)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .contextMenu{
                            RecordItemContextMenu(record: record)
                        }
                    
                }
                TableColumn("Name"){record in
                    Text(record.name!)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .contextMenu{
                            RecordItemContextMenu(record: record)
                        }
                }
                
                TableColumn("Proxied"){record in
                    Text("\(record.proxied.description)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .contextMenu{
                            RecordItemContextMenu(record: record)
                        }
                }
                
                TableColumn("IP Address"){record in
                    if let status = record.status {
                        Text(status)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    } else {
                        Text(record.ipAddress!)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .contextMenu{
                                RecordItemContextMenu(record: record)
                            }
                    }
                }
            }
            .contextMenu{
                VStack{
                    Button(action: { showAddRecord = true }){
                        Text("Add a dns record")
                    }
                }
                
            }
        }
        .padding(.all)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .toolbar{
            Button(action: {showAddRecord = true}){
                Image(systemSymbol: SFSymbol.plus)
            }
            Button(action: {}){
                Image(systemSymbol: SFSymbol.pencil)
            }
        }
        .sheet(isPresented: $showAddRecord){
            RecordForm(host: host, onClose: { showAddRecord = false }){ record in
                dnsUpdateModel.records.append(record)
                showAddRecord = false
            }
        }
        .navigationTitle(dnsUpdateModel.getTitle(title: host.domainName ?? ""))
        .onAppear{
            dnsUpdateModel.records =  Array(host.records! as! Set<DNSRecord>)
            dnsUpdateModel.host = host
        }
    }
    
    
}
