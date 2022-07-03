//
//  IPAddressModel.swift
//  ddns
//
//  Created by Qiwei Li on 6/7/22.
//

import Foundation
import Alamofire
import CoreData


class IPAddressModel: ObservableObject{
    /**
     IP Address for current machine
     */
    @Published var ipAddress = ""

    @MainActor
    func update() async{
        do{
            let task = AF.request("https://whatismyip-five.vercel.app/api").serializingDecodable(IpAddress.self)
            let value = try await task.value
            ipAddress = value.ip
        } catch{
            print("Cannot fetch ip address")
        }
    }
}
