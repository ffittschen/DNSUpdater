//
//  EnvVariables.swift
//  App
//
//  Created by Florian Fittschen on 09.03.19.
//

import Foundation

/// Environment variables required by the DNSUpdates
enum EnvVariables: String, CaseIterable {
    /// A username that has to be used with Basic authentication to access the DNSUpdater
    case username = "USERNAME"

    /// A password that has to be used with Basic authentication to access the DNSUpdater
    case password = "PASSWORD"

    /// An API key to access the DigitalOcean API
    case apiKey = "API_KEY"
}
