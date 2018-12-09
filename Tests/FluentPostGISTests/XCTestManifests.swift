import XCTest

extension FluentPostGISTests {
    static let __allTests = [
        ("testPoint", testPoint),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FluentPostGISTests.__allTests),
    ]
}
#endif
