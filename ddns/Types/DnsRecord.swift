//
//  dnsRecord.swift
//  ddns
//
//  Created by Qiwei Li on 6/8/22.
//

import Foundation


enum DNSRecordType: String, CaseIterable, Codable{
    case A = "A"
    case AAAA = "AAAA"
    case CAA = "CAA"
    case CART = "CART"
    case CNAME = "CNAME"
    case DNSKEY = "DNSKEY"
    case DS = "DS"
    case HTTPS = "HTTPS"
    case LOC = "LOC"
    case MX = "MX"
    case NAPTR = "NAPTR"
    case NS = "NS"
    case PTR = "PTR"
    case SMIMEA = "SMIMEA"
    case SPF = "SPF"
    case SRV = "SRV"
    case SSHFP = "SSHFP"
    case SVCB = "SVCB"
    case TLSA = "TLSA"
    case TXT = "TXT"
    case URI = "URI"
}
