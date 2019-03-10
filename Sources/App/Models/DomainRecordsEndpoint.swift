//
//  DomainRecordsEndpoint.swift
//  App
//
//  Created by Florian Fittschen on 09.03.19.
//

import Vapor

enum DomainRecordsEndpoint {
    case listRecords(domainName: String)
    case updateRecord(domainName: String, id: Int)
}

extension DomainRecordsEndpoint: URLRepresentable {
    static let baseURL = URL(string: "https://api.digitalocean.com")
    static let apiVersion = "v2"

    var path: String {
        switch self {
        case let .listRecords(domainName):
            return "/\(DomainRecordsEndpoint.apiVersion)/domains/\(domainName)/records"
        case let .updateRecord(domainName, id):
            return "/\(DomainRecordsEndpoint.apiVersion)/domains/\(domainName)/records/\(id)"
        }
    }

    func convertToURL() -> URL? {
        return DomainRecordsEndpoint.baseURL?.appendingPathComponent(path)
    }
}
