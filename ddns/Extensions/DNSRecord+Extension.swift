//
//  DNSRecord+Extension.swift
//  ddns
//
//  Created by Qiwei Li on 7/2/22.
//

import Foundation

extension DNSRecord {
    
    func cloudflareDNSCreationParameter() -> CloudflareDNSCreationParameter{
        return CloudflareDNSCreationParameter(type: type!, name: name!, content: ipAddress!, proxied: false)
    }
}
