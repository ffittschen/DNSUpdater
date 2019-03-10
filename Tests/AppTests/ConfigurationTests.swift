//
//  ConfigurationTests.swift
//  AppTests
//
//  Created by Florian Fittschen on 10.03.19.
//

@testable import App
import Vapor
import XCTest
import FluentSQLite
import Authentication

final class ConfigurationTests: XCTestCase {

    var app: Application!

    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
    }

    override func tearDown() {
        try? app.syncShutdownGracefully()
    }

    func testUserIsPrepopulated() throws {
        let mockEnvironmentProvider = MockEnvironmentService(environmentVariables: TestConstants.envVars)
        try app.xctest()
            .override(service: EnvironmentProvider.self, with: mockEnvironmentProvider)
            .testSQLite(closure: { conn in
                guard let user = try User.query(on: conn).filter(\.username == TestConstants.username).first().wait() else {
                    XCTFail("User is not pre-populated.")
                    return
                }

                XCTAssertEqual(user.username, TestConstants.username)
                XCTAssert(try BCrypt.verify(TestConstants.password, created: user.passwordHash))
            })
    }

    static let allTests = [
        ("testUserIsPrepopulated", testUserIsPrepopulated)
    ]
}

