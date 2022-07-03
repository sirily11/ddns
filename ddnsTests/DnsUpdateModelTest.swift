//
//  ddnsTests.swift
//  ddnsTests
//
//  Created by Qiwei Li on 6/7/22.
//

import XCTest
@testable import ddns


class DnsUpdateModelTest: XCTestCase {
    var records: [DNSRecord] = []
    let ipAddress = "192.168.1.1"
    let ipAddress2 = "192.168.1.2"
    let ipAddress3 = "192.168.1.3"
    
    let context = PersistenceController.init(inMemory: true).container.viewContext
    
    override func setUpWithError() throws {
       let record1 = DNSRecord(context: context)
        record1.watch = true
        record1.ipAddress = ipAddress
        
        let record2 = DNSRecord(context: context)
        record2.watch = true
        record2.ipAddress = ipAddress
        
        let record3 = DNSRecord(context: context)
        record3.watch = false
        record3.ipAddress = ipAddress2
        
        let record4 = DNSRecord(context: context)
        record4.watch = true
        record4.ipAddress = ipAddress2
        
        records = [record1, record2, record3, record4]
    }
    
    func testFindUpdates1() throws {
        let model = DnsUpdateModel()
        let result = model.findRecordsToUpdate(dns: records, ip: ipAddress)
        XCTAssertEqual(result.count, 1)
    }
    
    func testFindUpdates2() throws {
        let model = DnsUpdateModel()
        let result = model.findRecordsToUpdate(dns: records, ip: ipAddress2)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFindUpdates3() throws {
        let model = DnsUpdateModel()
        let result = model.findRecordsToUpdate(dns: records, ip: ipAddress3)
        XCTAssertEqual(result.count, 3)
    }

}
