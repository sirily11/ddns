//
//  DnsUpdateModel.swift
//  ddns
//
//  Created by Qiwei Li on 7/3/22.
//

import Foundation
import CoreData


class DnsUpdateModel: ObservableObject {
    @Published var totalUpdateRecords: [DNSRecord] = []
    @Published var finishedRecords: [DNSRecord] = []
    @Published var currentUpdatingHost: Host? = nil
    @Published var isUpdating = false
    
    @Published var records: [DNSRecord] = []
    @Published var host: Host?
    
    private var cloudflare: CloudflareClient = CloudflareClient()
    
    /**
     Update one record
     */
    func update(record: DNSRecord) {
        if let index = records.firstIndex(of: record) {
            records[index] = record
        }
    }
    
    /**
     Remove one record
     */
    func remove(record: DNSRecord) {
        if let index = records.firstIndex(of: record) {
            records.remove(at: index)
        }
    }
    
    
    /**
     Update all records in all hosts
     */
    @MainActor
    func update(hosts: [Host], ip: String) async throws{
        isUpdating = true
        totalUpdateRecords = []
        finishedRecords = []
        currentUpdatingHost = nil
        
        var dnsRecords: [DNSRecord] = []
        for host in hosts {
            if let records = host.records {
                for record in records {
                    dnsRecords.append(record as! DNSRecord)
                }
                totalUpdateRecords = findRecordsToUpdate(dns: dnsRecords, ip: ip)
                if totalUpdateRecords.count > 0 {
                    currentUpdatingHost = host
                }
                do {
                    try await updateRecords(host: host, records: dnsRecords, ip: ip)
                } catch let err {
                    print(err.localizedDescription)
                }
                dnsRecords = []
            }
        }
        
        isUpdating = false
    }
    
    /**
     Get navigation title
     */
    func getTitle(title: String) -> String{
        if isUpdating {
            if let currentUpdatingHost = currentUpdatingHost {
                return "Updating \(currentUpdatingHost.domainName ?? "") (\(finishedRecords.count)/\(totalUpdateRecords.count) )"
            }
            return "Updating \(title)"
        }
        return title
    }
    
    @MainActor
    private func updateRecords(host: Host, records: [DNSRecord], ip: String) async throws {
        for record in records {
            record.ipAddress = ip
            do {
                let _ = try await cloudflare.use(host: host).updateDNSRecord(dns: record)
            } catch let error {
                print(error.localizedDescription)
            }
            finishedRecords.append(record)
        }
        
    }
    
    /**
     Given a list of records, returns a list of records need to be updated
     */
    func findRecordsToUpdate(dns: [DNSRecord], ip: String ) -> [DNSRecord]{
        let watchedRecords = dns.filter { record in
            record.watch
        }
        
        let changedResults = watchedRecords.filter { record in
            record.ipAddress != ip
        }
        
        return changedResults
    }
    
    /**
     Fetch remote dns records and replace the current one
     */
    @MainActor
    func updateUpstreamDnsRecords(context: NSManagedObjectContext, host: Host) async throws{
        isUpdating = true
        do {
            let result = try await cloudflare.use(host: host).listDNSRecords()
            let dnsRecords = result.result.map { result in
                result.toDnsRecord(context: context)
            }
            host.records = NSSet(array: dnsRecords)
            try context.save()
            
            if self.host == host {
                self.records = dnsRecords
            }
            
        } catch let error {
            throw error
        }
        isUpdating = false
    }
    
    
    /**
     Update one record
     */
    @MainActor
    func updateDnsRecord(context: NSManagedObjectContext, record: DNSRecord, ip: String) async {
        do {
            record.setStatus(.updating)
            update(record: record)
            record.ipAddress = ip
            let _ = try await cloudflare.use(host: host!).updateDNSRecord(dns: record)
            record.setStatus(nil)
            update(record: record)
            try context.save()
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    /**
     Delete one record
     */
    @MainActor
    func deleteDnsRecord(context: NSManagedObjectContext, record: DNSRecord) async {
        do {
            record.setStatus(.deleting)
            update(record: record)
            let _ = try await cloudflare.use(host: host!).deleteDNSRecord(dns: record)
            context.delete(record)
            record.setStatus(nil)
            try! context.save()
            remove(record: record)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}
