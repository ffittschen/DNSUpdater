#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    testCase(AppTests.allTests),
    testCase(ConfigurationTests.allTests),
    testCase(DomainTests.allTests),
    testCase(EnvironmentDotEnvTests.allTests),
    testCase(FakeClientTests.allTests)
])

#endif
