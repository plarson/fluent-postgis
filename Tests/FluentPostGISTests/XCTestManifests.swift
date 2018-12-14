import XCTest

extension FluentPostGISTests {
    static let __allTests = [
        ("testContains", testContains),
        ("testContainsWithHole", testContainsWithHole),
        ("testGeometryCollection", testGeometryCollection),
        ("testLineString", testLineString),
        ("testPoint", testPoint),
        ("testPolygon", testPolygon),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FluentPostGISTests.__allTests),
    ]
}
#endif
