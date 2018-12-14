import XCTest

extension GeometryTests {
    static let __allTests = [
        ("testGeometryCollection", testGeometryCollection),
        ("testLineString", testLineString),
        ("testPoint", testPoint),
        ("testPolygon", testPolygon),
    ]
}

extension QueryTests {
    static let __allTests = [
        ("testContains", testContains),
        ("testContainsReversed", testContainsReversed),
        ("testContainsWithHole", testContainsWithHole),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GeometryTests.__allTests),
        testCase(QueryTests.__allTests),
    ]
}
#endif
