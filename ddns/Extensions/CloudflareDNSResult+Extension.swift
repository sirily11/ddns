//
//  CloudflareDNSResult+Extension.swift
//  ddns
//
//  Created by Qiwei Li on 7/4/22.
//

import Foundation
import CoreData

extension CloudflareDNSResult {
    func toDnsRecord(context: NSManagedObjectContext) -> DNSRecord {
        let dnsRecord = DNSRecord(context: context)
        dnsRecord.timestamp = Date()
        dnsRecord.type = type
        dnsRecord.name = name
        dnsRecord.ipAddress = content
        dnsRecord.proxied = proxied
        dnsRecord.cloudflareId = id
        dnsRecord.watch = true
        return dnsRecord
    }
}
