//
//  DomainRecord.swift
//  App
//
//  Created by Florian Fittschen on 10.03.19.
//

import Vapor

/// A domain record as defined by the DigitalOcean API
struct DomainRecord: Content {
    var id: Int // 28448432,
    var type: String // "A",
    var name: String // "@",
    var data: String // "1.2.3.4",
    var priority: Int? // null,
    var port: Int? // null,
    var ttl: Int // 1800,
    var weight: Int? // null,
    var flags: Int? // null,
    var tag: String? // null
}
