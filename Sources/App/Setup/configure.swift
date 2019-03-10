//
//  configure.swift
//  App
//
//  Created by Florian Fittschen on 09.03.19.
//

import Authentication
import FluentSQLite
import Vapor

/// Called before the application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    // Load environment variables from .env file
    Environment.dotenv()

    // Register EnvironmentProvider to store Environment Variables
    let environmentProvider = try EnvironmentService(keys: EnvVariables.allCases.map({ $0.rawValue }))
    services.register(environmentProvider, as: EnvironmentProvider.self)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .sqlite)
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)

    // pre-populate database with user
    migrations.add(migration: PopulateUser.self, database: .sqlite)

    services.register(migrations)

    // Register fluent commands to perform migrations or revert them
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}
