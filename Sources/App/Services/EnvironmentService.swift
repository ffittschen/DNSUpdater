//
//  EnvironmentService.swift
//  App
//
//  Created by Florian Fittschen on 09.03.19.
//

import Vapor

protocol EnvironmentProvider {
    var environmentVariables: [String: String] { get }
}

struct EnvironmentService: Service {
    var environmentVariables = [String: String]()

    init(keys: [String]) throws {
        for key in keys {
            try environmentVariables[key] = Environment.get(key) ?! Abort(.badRequest, reason: "'\(key)' is missing")
        }
    }
}
