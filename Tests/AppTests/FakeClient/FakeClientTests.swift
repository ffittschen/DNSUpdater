//
//  FakeClientTests.swift
//  AppTests
//
//  Created by Florian Fittschen on 10.03.19.
//

@testable import App
import Vapor
import XCTest

final class FakeClientTests: XCTestCase {

    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        try? app.syncShutdownGracefully()
    }

    func testFakeClient() throws {
        try app.xctest()
            .override(service: Client.self, with: { FakeClient(container: $0) })
            .override(service: Router.self, with: { container -> EngineRouter in
                let router = EngineRouter.default()
                let client = try container.make(Client.self)
                router.get("client") { req in
                    client.get("http://httpbin.org/status/201")
                }
                return router
            })
            .test(.GET, to: "/client") { res in
                res.assertStatus(is: .ok)
        }
    }

    static let allTests = [
        ("testFakeClient", testFakeClient)
    ]
}
