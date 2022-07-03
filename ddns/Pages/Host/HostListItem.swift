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
            Button(action: { viewContext.delete(host) }){
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
        await updateDomainName()
    }
    
    func updateDomainName() async {
        isLoading = true
        if host.domainName == nil {
            return
        }
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
