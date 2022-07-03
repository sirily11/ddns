//
//  HostListItem.swift
//  ddns
//
//  Created by Qiwei Li on 7/2/22.
//

import SwiftUI

struct HostListItem: View {
    var host: Host
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cloudflareClient: CloudflareClient
    @EnvironmentObject var dnsUpdateModel: DnsUpdateModel
    
    @State var error: Error?
    @State var showError = false
    @State var isLoading: Bool = false
    
    init(host: Host){
        self.host = host
    }
    
    var body: some View {
        NavigationLink(destination: {
            if !isLoading {
                RecordDetail(host: host)
            }
        }){
            HStack{
                if let domainName = host.domainName{
                    if !isLoading {
                        Text(domainName)
                    }
                }
                if isLoading {
                    Text("Loading...")
                }
                Spacer()
                
                if let error = error {
                    Image(systemSymbol: .infoCircleFill)
                        .foregroundColor(.red)
                        .onTapGesture{
                            showError = true
                        }
                        .popover(isPresented: $showError) {
                            Text("\(error.localizedDescription)")
                                .padding()
                        }
                }
            }
        }
        .contextMenu{
            Button(action: { delete(host: host) }){
                Text("Delete")
            }
            Button(action: { Task{ await refresh()} }){
                Text("Refresh")
            }
        }
        .task {
            await updateDomainName()
        }
    }
    
    func refresh() async {
        do {
            await updateDomainName()
            try await dnsUpdateModel.updateDnsRecords(context: viewContext, cloudflare: cloudflareClient, host: host)
        } catch let error {
            self.error = error
        }
    }
    
    
    func delete(host: Host) {
        do {
            viewContext.delete(host)
            try viewContext.save()
        } catch let error {
            print(error.localizedDescription)
            self.error = error
        }
    }
    
    
    func updateDomainName() async {
        if host.domainName != nil {
            return
        }
        isLoading = true
        do {
            let zoneInfo = try await cloudflareClient.use(host: host).getZone()
            if let result = zoneInfo.result {
                host.domainName = result.name
                try viewContext.save()
            }
        } catch let error {
            self.error = error
        }
        isLoading = false
    }
}
struct HostListItem_Previews: PreviewProvider {
    static var previews: some View {
        HostListItem(host: Host())
    }
}
