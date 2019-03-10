//
//  TestConstants.swift
//  AppTests
//
//  Created by Florian Fittschen on 10.03.19.
//

@testable import App

enum TestConstants {
    static let testDomain = "example.com"
    static let badDomain = "foobar.com"
    static let testRecordId = 3352896
    static let testRecordName = "foo"
    static let badRecordName = "foo"
    static let testIp = "1.2.3.4"
    static let username = "some_user"
    static let password = "123456"
    static let apiKey = "123123qweqwe123123"
    static let domainsURI = "/api/v1/domains/updateRecord"
    static let query = "?domain=\(testDomain)&recordName=\(testRecordName)&ip=\(testIp)"
    static let badQuery = "?domain=\(badDomain)&recordName=\(badRecordName)&ip=\(testIp)"
    static let envVars = [
        EnvVariables.username.rawValue: username,
        EnvVariables.password.rawValue: password,
        EnvVariables.apiKey.rawValue: apiKey
    ]
}
