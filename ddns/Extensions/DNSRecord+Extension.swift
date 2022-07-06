//
//  DNSRecord+Extension.swift
//  ddns
//
//  Created by Qiwei Li on 7/2/22.
//

import Foundation

extension DNSRecord {
    
    func setStatus(_ status: DNSRecordStatus?) {
        self.status = status?.rawValue
    }
    
    func cloudflareDNSCreationParameter() -> CloudflareDNSCreationParameter{
        return CloudflareDNSCreationParameter(type: type!, name: name!, content: ipAddress!, proxied: proxied)
    }
}


enum DNSRecordStatus: String, Codable {
    case updating
    case deleting
    
}
