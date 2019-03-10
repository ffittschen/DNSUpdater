//
//  AppTests.swift
//  AppTests
//
//  Created by Florian Fittschen on 09.03.19.
//

import XCTest
import Vapor
@testable import App

class AppTests: XCTestCase {

    func testApplicationStarts() throws {
        let test = Environment(name: "testing", isRelease: false, arguments: ["vapor"])
        let testApp = try app(test)
        try testApp.asyncRun().wait()
    }
    
    static let allTests = [
        ("testApplicationStarts", testApplicationStarts),
    ]
}
