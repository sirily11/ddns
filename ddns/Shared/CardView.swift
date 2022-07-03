//
//  CardView.swift
//  ddns
//
//  Created by Qiwei Li on 6/7/22.
//

import SwiftUI

struct CardView<Content: View>: View {
    @ViewBuilder let view: Content
    
    var body: some View {
        VStack{
            view
        }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(15)
        
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView{
            Text("Hello world")
        }
    }
}
