//
//  DomainTests.swift
//  AppTests
//
//  Created by Florian Fittschen on 09.03.19.
//

@testable import App
import Vapor
import XCTest

final class DomainTests: XCTestCase {

    var app: Application!
    var xctapp: XCTApplication!

    override func setUp() {
        app = try! Application.testable()
        xctapp = app.xctest()
    }

    override func tearDown() {
        try? app.syncShutdownGracefully()
        xctapp = nil
    }

    func testUpdateRecordFails_whenUserNotAuthenticated() throws {
        let mockEnvironmentProvider = MockEnvironmentService(environmentVariables: [:])
        try xctapp
            .override(service: EnvironmentProvider.self, with: mockEnvironmentProvider)
            .override(service: Client.self, with: { container -> FakeClient in
                return FakeClient(container: container)
            })
            .test(.GET, to: TestConstants.domainsURI + TestConstants.query, closure: { response in
                response.assertStatus(is: HTTPResponseStatus.unauthorized)
                response.assertBody(contains: "User has not been authenticated.")
            })
    }

    func testUpdateRecordFails_whenAPIKeyIsMissing() throws {
        var envVars = TestConstants.envVars
        envVars[EnvVariables.apiKey.rawValue] = nil
        let mockEnvironmentProvider = MockEnvironmentService(environmentVariables: envVars)
        var headers = HTTPHeaders()
        headers.basicAuthorization = BasicAuthorization(username: TestConstants.username, password: TestConstants.password)
        try xctapp
            .override(service: EnvironmentProvider.self, with: mockEnvironmentProvider)
            .override(service: Client.self, with: { container -> FakeClient in
                return FakeClient(container: container)
            })
            .test(.GET, to: TestConstants.domainsURI + TestConstants.query, headers: headers, closure: { response in
                response.assertStatus(is: HTTPResponseStatus.internalServerError)
                response.assertBody(contains: "API_KEY is missing.")
            })
    }

    func testUpdateRecordFails_whenSuppliedRecordNameIsMissing() throws {
        let mockEnvironmentProvider = MockEnvironmentService(environmentVariables: TestConstants.envVars)
        var headers = HTTPHeaders()
        headers.basicAuthorization = BasicAuthorization(username: TestConstants.username, password: TestConstants.password)
        try xctapp
            .override(service: EnvironmentProvider.self, with: mockEnvironmentProvider)
            .override(service: Client.self, with: { container -> FakeClient in
                return FakeClient(container: container)
            })
            .test(.GET, to: TestConstants.domainsURI + TestConstants.badQuery, headers: headers, closure: { response in
                response.assertStatus(is: HTTPResponseStatus.badRequest)
                response.assertBody(contains: "Could not find record with name")
                response.assertBody(contains: "foo")
            })
    }

    func testUpdateRecord() throws {
        let mockEnvironmentProvider = MockEnvironmentService(environmentVariables: TestConstants.envVars)
        var headers = HTTPHeaders()
        headers.basicAuthorization = BasicAuthorization(username: TestConstants.username, password: TestConstants.password)
        try xctapp
            .override(service: EnvironmentProvider.self, with: mockEnvironmentProvider)
            .override(service: Client.self, with: { container -> FakeClient in
                return FakeClient(container: container)
            })
            .test(.GET, to: TestConstants.domainsURI + TestConstants.query, headers: headers, closure: { response in
                response.assertStatus(is: HTTPResponseStatus.ok)
                response.assertBody(contains: "domain_record")
                response.assertBody(contains: "1.2.3.4")
            })
    }

    func testLinuxTestSuiteIncludesAllTests() throws {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.allTests.count
        let darwinCount = Int(thisClass.defaultTestSuite.testCaseCount)

        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }

    static let allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testUpdateRecordFails_whenUserNotAuthenticated", testUpdateRecordFails_whenUserNotAuthenticated),
        ("testUpdateRecordFails_whenAPIKeyIsMissing", testUpdateRecordFails_whenAPIKeyIsMissing),
        ("testUpdateRecordFails_whenSuppliedRecordNameIsMissing", testUpdateRecordFails_whenSuppliedRecordNameIsMissing),
        ("testUpdateRecord", testUpdateRecord),
    ]
}
