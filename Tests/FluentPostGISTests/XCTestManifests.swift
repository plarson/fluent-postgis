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
        ("testCrosses", testCrosses),
        ("testCrossesReversed", testCrossesReversed),
        ("testDisjoint", testDisjoint),
        ("testDisjointReversed", testDisjointReversed),
        ("testEquals", testEquals),
        ("testIntersects", testIntersects),
        ("testIntersectsReversed", testIntersectsReversed),
        ("testOverlaps", testOverlaps),
        ("testOverlapsReversed", testOverlapsReversed),
        ("testTouches", testTouches),
        ("testTouchesReversed", testTouchesReversed),
        ("testWithin", testWithin),
        ("testWithinReversed", testWithinReversed),
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
