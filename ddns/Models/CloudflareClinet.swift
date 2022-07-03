//
//  CloudflareClinet.swift
//  ddns
//
//  Created by Qiwei Li on 7/2/22.
//

import Foundation
import Alamofire

class CloudflareClient: ObservableObject {
    private var host: Host?
    let baseURL = URL(string: "https://api.cloudflare.com/client/v4")
    var headers: HTTPHeaders? {
        get {
            if let host = host {
                return [.authorization(bearerToken: host.apiKey!)]
            }
            return nil
        }
    }
    
    
    func use(host: Host) -> CloudflareClient {
        self.host = host
        return self
    }
    
   
    func listDNSRecords() async throws -> CloudflareArrayResult<CloudflareDNSResult> {
        if let baseURL = baseURL {
            if let host = host {
                let url = baseURL
                    .appendingPathComponent("zones")
                    .appendingPathComponent(host.zoneId!)
                    .appendingPathComponent("dns_records")
                let task = AF.request(url,
                                      method: .get,
                                      headers: headers!)
                            .serializingDecodable(CloudflareArrayResult<CloudflareDNSResult>.self)
                let value = try await task.value
                return value
            }
        }
        throw InvalidHostError.notInit
    }
    
    func createDNSRecord(dns: DNSRecord) async throws -> CloudflareResult<CloudflareDNSResult> {
        if let baseURL = baseURL {
            if let host = host {
                let url = baseURL
                    .appendingPathComponent("zones")
                    .appendingPathComponent(host.zoneId!)
                    .appendingPathComponent("dns_records")
                let task = AF.request(url,
                                      method: .post,
                                      parameters: dns.cloudflareDNSCreationParameter(),
                                      encoder: JSONParameterEncoder(),
                                      headers: headers!)
                    .serializingDecodable(CloudflareResult<CloudflareDNSResult>.self)
                let value = try await task.value
                return value
            }
        }
        throw InvalidHostError.notInit
    }
    
    /**
     Update dns record using cloudflare API from dnsrecord class.
     If dns doesn't have a cloudflare id associate with it, then an updateError will be thrown.
     */
    func updateDNSRecord(dns: DNSRecord) async throws -> CloudflareResult<CloudflareDNSResult> {
        if let baseURL = baseURL {
            if let host = host {
                if let cloudflareId = dns.cloudflareId {
                    let url = baseURL
                        .appendingPathComponent("zones")
                        .appendingPathComponent(host.zoneId!)
                        .appendingPathComponent("dns_records")
                        .appendingPathComponent(cloudflareId)
                    let task = AF.request(url,
                                          method: .patch,
                                          parameters: dns.cloudflareDNSCreationParameter(),
                                          encoder: JSONParameterEncoder(),
                                          headers: headers!)
                        .serializingDecodable(CloudflareResult<CloudflareDNSResult>.self)
                    let value = try await task.value
                    return value
                }
                throw CloudflareClientError.updateError(reason: "Missing cloudflare ID")
            
            }
        }
        throw InvalidHostError.notInit
    }
    
    /**
     Delete dns record using cloudflare API from dnsrecord class.
     If dns doesn't have a cloudflare id associate with it, then an updateError will be thrown.
     */
    func deleteDNSRecord(dns: DNSRecord) async throws {
        if let baseURL = baseURL {
            if let host = host {
                if let cloudflareId = dns.cloudflareId {
                    let url = baseURL
                        .appendingPathComponent("zones")
                        .appendingPathComponent(host.zoneId!)
                        .appendingPathComponent("dns_records")
                        .appendingPathComponent(cloudflareId)
                    let task = AF.request(url,
                                          method: .delete,
                                          headers: headers!)
                        .serializingString()
                    let value = try await task.value
                    print(value)
                    return
                }
                throw CloudflareClientError.deletionError(reason: "Missing cloudflare ID")
            }
        }
        throw InvalidHostError.notInit
    }
    
    
    /**
     Fetch host zone detail by zone id
     */
    func getZone() async throws -> CloudflareResult<CloudflareZoneDetailResult> {
        if let baseURL = baseURL {
            if let host = host {
                let url = baseURL
                    .appendingPathComponent("zones")
                    .appendingPathComponent(host.zoneId!)
                let task = AF.request(url,
                                      method: .get,
                                      headers: headers!)
                    .serializingDecodable(CloudflareResult<CloudflareZoneDetailResult>.self)
                let value = try await task.value
                return value
            }
        }
        throw InvalidHostError.notInit
    }
}
