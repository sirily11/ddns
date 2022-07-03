//
//  HostList.swift
//  ddns
//
//  Created by Qiwei Li on 6/7/22.
//

import SwiftUI
import SFSafeSymbols

struct HostList: View {
    let hosts: FetchedResults<Host>
    @State private var showAdd = false
    @Environment(\.managedObjectContext) private var viewContext

    
    var body: some View {
        VStack {
            List{
                ForEach(hosts){ host in
                    HostListItem(host: host)
                }
            }
        }
        .toolbar{
            Button(action: { showAdd = true }){
                Image(systemSymbol: SFSymbol.plus)
            }
        }
        .sheet(isPresented: $showAdd){
            HostForm(
                onClose: {
                    showAdd = false
                })
        }
    }
}
