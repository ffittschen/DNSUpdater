//
//  Application+Testable.swift
//  AppTests
//
//  Created by Florian Fittschen on 09.03.19.
//

import Vapor
import FluentSQLite
@testable import App

extension Application {

    static func testable(envArgs: [String]? = nil) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing

        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }

        config.prefer(FakeClient.self, for: Client.self)
        config.prefer(MockEnvironmentService.self, for: EnvironmentProvider.self)
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)

        try App.boot(app)
        return app
    }

    static func reset() throws {
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.testable(envArgs: revertEnvironment).asyncRun().wait()
        let migrateEnvironment = ["vapor", "migrate", "-y"]
        try Application.testable(envArgs: migrateEnvironment).asyncRun().wait()
    }
}
