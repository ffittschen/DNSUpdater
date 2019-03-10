//
//  routes.swift
//  App
//
//  Created by Florian Fittschen on 09.03.19.
//

import Crypto
import Vapor

public func routes(_ router: Router) throws {
    let domainController = DomainController()
    
    // basic / password auth protected routes
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    try basic.register(collection: domainController)
}
