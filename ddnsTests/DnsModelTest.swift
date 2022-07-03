//
//  DnsModelTest.swift
//  ddnsTests
//
//  Created by Qiwei Li on 7/3/22.
//

import XCTest
@testable import ddns

typealias Host = ddns.Host

class DnsModelTest: XCTestCase {
    let ipAddress = "192.168.1.1"
    let ipAddress2 = "192.168.1.2"
    let ipAddress3 = "192.168.1.3"
    
    func setupRecords(context: NSManagedObjectContext) -> [DNSRecord]{
       let record1 = DNSRecord(context: context)
        record1.name = "a"
        record1.watch = true
        record1.ipAddress = ipAddress
        record1.type = "A"
        record1.timestamp = Date()
        
        let record2 = DNSRecord(context: context)
        record2.name = "b"
        record2.watch = true
        record2.ipAddress = ipAddress
        record2.type = "A"
        record2.timestamp = Date()
        
        let record3 = DNSRecord(context: context)
        record3.name = "c"
        record3.watch = false
        record3.ipAddress = ipAddress2
        record3.type = "A"
        record3.timestamp = Date()
        
        let record4 = DNSRecord(context: context)
        record4.name = "d"
        record4.watch = true
        record4.ipAddress = ipAddress2
        record4.type = "A"
        record4.timestamp = Date()
        
        let records = [record1, record2, record3, record4]
        return records
    }
    
    func testDelete() throws {
        let context = PersistenceController.init(inMemory: true).container.viewContext
        let host = Host(context: context)
        host.records = NSSet(array: self.setupRecords(context: context))
        host.domainName = "mock.com"
        host.zoneId = "mock"
        host.apiKey = "mock_key"
        
        try context.save()
        
        context.delete(host)
        try context.save()
    }
    
    func testToDnsRecord() throws {
        let context = PersistenceController.init(inMemory: true).container.viewContext
        let host = Host(context: context)
        host.domainName = "mock2.com"
        host.zoneId = "mock2"
        host.apiKey = "mock_key2"
        
        let cloudflareRecord = CloudflareDNSResult(id: "372", type: "A", name: "example.com", content: "192.168.1.1", proxied: true)
        let record = cloudflareRecord.toDnsRecord(context: context)
        
        host.addToRecords(record)
        try context.save()
    }
    
    func testToDnsRecord2() throws {
        let context = PersistenceController.init(inMemory: true).container.viewContext
        let host = Host(context: context)
        host.domainName = "mock.com"
        host.zoneId = "mock"
        host.apiKey = "mock_key"

        let cloudflareRecord = CloudflareDNSResult(id: "372", type: "A", name: "example.com", content: "192.168.1.1", proxied: true)
        let record = cloudflareRecord.toDnsRecord(context: context)

        host.records = NSSet(array: [record])
        try context.save()
    }
    
    func testToDnsRecord3() throws {
        let context = PersistenceController.init(inMemory: true).container.viewContext
        let host = Host(context: context)
        host.domainName = "mock.com"
        host.zoneId = "mock"
        host.apiKey = "mock_key"

        let cloudflareRecord = CloudflareDNSResult(id: "372", type: "A", name: "example.com", content: "192.168.1.1", proxied: true)
        
        let cloudflareRecord2 = CloudflareDNSResult(id: "373", type: "A", name: "example.com", content: "192.168.1.2", proxied: true)
        let record = cloudflareRecord.toDnsRecord(context: context)

        host.records = NSSet(array: [record])
        try context.save()
        
        host.records = NSSet(array: [cloudflareRecord2.toDnsRecord(context: context)])
        try context.save()
    }
}
