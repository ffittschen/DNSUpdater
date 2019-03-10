//
//  DomainController.swift
//  App
//
//  Created by Florian Fittschen on 05.03.19.
//

import Crypto
import Vapor
import FluentSQLite

struct DomainController: RouteCollection {
    func boot(router: Router) throws {
        let domainRoutes = router.grouped("api", "v1", "domains")
        domainRoutes.get("updateRecord", use: updateRecord)
    }

    /// Updates a domain record.
    func updateRecord(_ req: Request) throws -> Future<UpdateDomainRecordsResponseContainer> {
        // fetch auth'd user
        _ = try req.requireAuthenticated(User.self)

        let updateRecordRequest = try req.query.decode(IncomingUpdateRecordRequest.self)
        let environmentProvider = try req.make(EnvironmentProvider.self)
        let apiKey = try environmentProvider.environmentVariables[EnvVariables.apiKey.rawValue] ?! Abort(.internalServerError, reason: "\(EnvVariables.apiKey.rawValue) is missing.")
        let domainListFuture = try req.client()
            .get(DomainRecordsEndpoint.listRecords(domainName: updateRecordRequest.domain)) { request in
                request.http.contentType = MediaType.json
                request.http.headers.bearerAuthorization = BearerAuthorization(token: apiKey)
            }
            .flatMap { response in
                return try response.content.decode(ListDomainRecordsResponseContainer.self)
            }

        return domainListFuture.flatMap { listRecordsResponse -> Future<UpdateDomainRecordsResponseContainer> in
            guard let record = listRecordsResponse.domainRecords.first(where: { $0.name == updateRecordRequest.recordName }) else {
                throw Abort(.badRequest, reason: "Could not find record with name '\(updateRecordRequest.recordName)'")
            }

            return try req.client().put(DomainRecordsEndpoint.updateRecord(domainName: updateRecordRequest.domain, id: record.id)) { request in
                request.http.contentType = MediaType.json
                request.http.headers.bearerAuthorization = BearerAuthorization(token: apiKey)
                try request.content.encode(OutgoingUpdateRecordRequest(data: updateRecordRequest.ip))
            }
            .flatMap { response in
                return try response.content.decode(UpdateDomainRecordsResponseContainer.self)
            }
        }
    }
}

// MARK: Content

/// Incoming GET request to update the `recordName` of `domain` to `ip`
struct IncomingUpdateRecordRequest: Content {
    var domain: String
    var recordName: String
    var ip: String
}

/// Outgoing request to update the domain record to the ip contained in `data`
struct OutgoingUpdateRecordRequest: Content {
    var data: String
}

struct ListDomainRecordsResponseContainer: Content {
    var domainRecords: [DomainRecord]

    enum CodingKeys: String, CodingKey {
        case domainRecords = "domain_records"
    }
}

struct UpdateDomainRecordsResponseContainer: Content {
    var domainRecord: DomainRecord

    enum CodingKeys: String, CodingKey {
        case domainRecord = "domain_record"
    }
}
