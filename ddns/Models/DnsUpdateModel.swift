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
    
    func update(record: DNSRecord) {
        if let index = records.firstIndex(of: record) {
            records[index] = record
        }
    }
    
    func remove(record: DNSRecord) {
        if let index = records.firstIndex(of: record) {
            records.remove(at: index)
        }
    }
    
    
    @MainActor
    func update(hosts: [Host], ip: String, cloudflareClient: CloudflareClient) async throws{
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
                    try await updateRecords(records: dnsRecords, ip: ip, cloudflareClient: cloudflareClient)
                } catch let err {
                    print(err.localizedDescription)
                }
                dnsRecords = []
            }
        }
        
        isUpdating = false
    }
    
    func getTitle(title: String) -> String{
        if isUpdating {
            if let currentUpdatingHost = currentUpdatingHost {
                return "Updating \(currentUpdatingHost.domainName ?? "") (\(finishedRecords.count)/\(totalUpdateRecords.count) )"
            }
            return "Updating \(title)"
        }
        return title
    }
    
    
    private func updateRecords(records: [DNSRecord], ip: String, cloudflareClient: CloudflareClient) async throws {
        for record in records {
            record.ipAddress = ip
            do {
                let _ = try await cloudflareClient.updateDNSRecord(dns: record)
            } catch let error {
                print(error.localizedDescription)
            }
            finishedRecords.append(record)
        }
        
    }
    
    func findRecordsToUpdate(dns: [DNSRecord], ip: String ) -> [DNSRecord]{
        let watchedRecords = dns.filter { record in
            record.watch
        }
        
        let changedResults = watchedRecords.filter { record in
            record.ipAddress != ip
        }
        
        return changedResults
    }
    
    @MainActor
    func updateDnsRecords(context: NSManagedObjectContext, cloudflare: CloudflareClient, host: Host) async throws{
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
}
