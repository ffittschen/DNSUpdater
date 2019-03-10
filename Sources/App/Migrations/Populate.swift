//
//  Populate.swift
//  App
//
//  Created by Florian Fittschen on 09.03.19.
//

import Vapor
import Authentication
import FluentSQLite

/// Pre-populates the database with a user created by parsing the environment variables
final class PopulateUser: Migration {
    typealias Database = SQLiteDatabase

    static let user: User? = {
        guard let username = Environment.get(EnvVariables.username.rawValue) else { return nil }
        guard let password = Environment.get(EnvVariables.password.rawValue) else { return nil }
        // hash user's password using BCrypt
        guard let hash = try? BCrypt.hash(password) else { return nil }
        let user = User(username: username, passwordHash: hash)
        return user
    }()

    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        guard let user = user else { return conn.eventLoop.newFailedFuture(error: Error.couldNotInitUser) }
        return user.create(on: conn).map(to: Void.self) { _ in }
    }

    static func revert(on conn: SQLiteConnection) -> Future<Void> {
        guard let user = user else { return conn.eventLoop.newFailedFuture(error: Error.couldNotInitUser) }
        return User.query(on: conn).filter(\User.username == user.username).delete()
    }

}

extension PopulateUser {
    enum Error: Debuggable {
        case couldNotInitUser
        case couldNotDeleteUser

        // MARK: - Debuggable
        var identifier: String {
            switch self {
            case .couldNotInitUser:
                return "couldNotInitUser"
            case .couldNotDeleteUser:
                return "couldNotDeleteUser"
            }
        }

        var reason: String {
            switch self {
            case .couldNotInitUser:
                return "User could not be initialized. Please check if all required environment variables are provided."
            case .couldNotDeleteUser:
                return "User could not be deleted. Please check if all required environment variables are provided."
            }
        }
    }
}
