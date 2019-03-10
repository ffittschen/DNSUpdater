//
//  XCTApplication.swift
//  AppTests
//
//  Created by Florian Fittschen on 10.03.19.
//

import Vapor
import XCTest
import FluentSQLite

extension Application {
    public func xctest() -> XCTApplication {
        return .init(app: self)
    }
}


public final class XCTApplication {
    public let app: Application
    private var serviceOverrides: [(inout Services) -> ()]

    private var _container: Container?
    public init(app: Application) {
        self.app = app
        self.serviceOverrides = []
    }

    @discardableResult
    public func override<S>(service: Any.Type, with value: S) -> XCTApplication where S: Service {
        return self.override(service: service) { _ in value }
    }

    public func override<S>(service: Any.Type, with factory: @escaping (Container) throws -> S) -> XCTApplication where S: Service {
        self.serviceOverrides.append({ services in
            services.register(service, factory: factory)
        })
        return self
    }

    @discardableResult
    public func test(
        _ method: HTTPMethod,
        to string: String,
        headers: HTTPHeaders = .init(),
        file: StaticString = #file,
        line: UInt = #line,
        closure: (XCTHTTPResponse) throws -> () = { _ in }
    ) throws -> XCTApplication {
        let container = try self.container()
        let res = try container.make(Responder.self).respond(
            to: Request(http: HTTPRequest(method: method, url: string, headers: headers),
                        using: container)
        ).wait().http
        try closure(.init(response: res))
        return self
    }

    @discardableResult
    public func testSQLite(
        file: StaticString = #file,
        line: UInt = #line,
        closure: (SQLiteConnection) throws -> () = { _ in }
    ) throws -> XCTApplication {
        let container = try self.container()
        let conn = try container.newConnection(to: .sqlite).wait()
        try closure(conn)
        conn.close()
        return self
    }

    private func container() throws -> Container {
        if let existing = self._container {
            return existing
        } else {
            var services = self.app.services
            for override in self.serviceOverrides {
                override(&services)
            }
            let new = try Application.asyncBoot(
                config: app.config,
                environment: app.environment,
                services: services
            ).wait()
            self._container = new
            return new
        }
    }
}
