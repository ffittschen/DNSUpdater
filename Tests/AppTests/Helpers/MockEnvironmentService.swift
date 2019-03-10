//
//  MockEnvironmentService.swift
//  AppTests
//
//  Created by Florian Fittschen on 09.03.19.
//

import Vapor
@testable import App

struct MockEnvironmentService: Service, EnvironmentProvider {
    var environmentVariables = [String: String]()
}
