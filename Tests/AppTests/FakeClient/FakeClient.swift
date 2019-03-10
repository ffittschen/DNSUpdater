//
//  FakeClient.swift
//  AppTests
//
//  Created by Florian Fittschen on 10.03.19.
//

import Vapor

@testable import App

final class FakeClient: Service, Client {
    var container: Container
    var reqs: [HTTPRequest]

    init(container: Container) {
        self.reqs = []
        self.container = container
    }

    func send(_ req: Request) -> EventLoopFuture<Response> {
        self.reqs.append(req.http)
        let response = fakeResponse(for: req, in: container)
        return EmbeddedEventLoop().newSucceededFuture(result: response)
    }
}

extension FakeClient {
    func fakeResponse(for request: Request, in container: Container) -> Response {
        switch request.http.url.path {
        case DomainRecordsEndpoint.listRecords(domainName: TestConstants.testDomain).path:
            let httpResponse = HTTPResponse(status: .ok, body: FakeClient.listRecordsBody)
            let response = Response(http: httpResponse, using: container)
            response.http.contentType = .json
            return response
        case DomainRecordsEndpoint.listRecords(domainName: TestConstants.badDomain).path:
            let httpResponse = HTTPResponse(status: .ok, body: FakeClient.badListRecordsBody)
            let response = Response(http: httpResponse, using: container)
            response.http.contentType = .json
            return response
        case DomainRecordsEndpoint.updateRecord(domainName: TestConstants.testDomain, id: TestConstants.testRecordId).path:
            let httpResponse = HTTPResponse(status: .ok, body: FakeClient.updateRecordBody)
            let response = Response(http: httpResponse, using: container)
            response.http.contentType = .json
            return response
        default:
            return Response(http: .init(), using: container)
        }
    }

    static let listRecordsBody = """
        {
          "domain_records": [
            {
              "id": 28448429,
              "type": "NS",
              "name": "@",
              "data": "ns1.digitalocean.com",
              "priority": null,
              "port": null,
              "ttl": 1800,
              "weight": null,
              "flags": null,
              "tag": null
            },
            {
              "id": 28448430,
              "type": "NS",
              "name": "@",
              "data": "ns2.digitalocean.com",
              "priority": null,
              "port": null,
              "ttl": 1800,
              "weight": null,
              "flags": null,
              "tag": null
            },
            {
              "id": 28448431,
              "type": "NS",
              "name": "@",
              "data": "ns3.digitalocean.com",
              "priority": null,
              "port": null,
              "ttl": 1800,
              "weight": null,
              "flags": null,
              "tag": null
            },
            {
              "id": \(TestConstants.testRecordId),
              "type": "A",
              "name": "\(TestConstants.testRecordName)",
              "data": "4.3.2.1",
              "priority": null,
              "port": null,
              "ttl": 1800,
              "weight": null,
              "flags": null,
              "tag": null
            }
          ],
          "links": {
          },
          "meta": {
            "total": 4
          }
        }
        """

    static let badListRecordsBody = """
        {
          "domain_records": [
            {
              "id": 28448429,
              "type": "NS",
              "name": "@",
              "data": "ns1.digitalocean.com",
              "priority": null,
              "port": null,
              "ttl": 1800,
              "weight": null,
              "flags": null,
              "tag": null
            },
            {
              "id": 28448430,
              "type": "NS",
              "name": "@",
              "data": "ns2.digitalocean.com",
              "priority": null,
              "port": null,
              "ttl": 1800,
              "weight": null,
              "flags": null,
              "tag": null
            },
            {
              "id": 28448431,
              "type": "NS",
              "name": "@",
              "data": "ns3.digitalocean.com",
              "priority": null,
              "port": null,
              "ttl": 1800,
              "weight": null,
              "flags": null,
              "tag": null
            },
            {
              "id": 28448432,
              "type": "A",
              "name": "@",
              "data": "1.2.3.4",
              "priority": null,
              "port": null,
              "ttl": 1800,
              "weight": null,
              "flags": null,
              "tag": null
            }
          ],
          "links": {
          },
          "meta": {
            "total": 4
          }
        }
        """

    static let updateRecordBody = """
        {
          "domain_record": {
            "id": \(TestConstants.testRecordId),
            "type": "A",
            "name": "\(TestConstants.testRecordName)",
            "data": "\(TestConstants.testIp)",
            "priority": null,
            "port": null,
            "ttl": 1800,
            "weight": null,
            "flags": null,
            "tag": null
          }
        }
        """
}
