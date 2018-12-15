import Foundation
import PostgreSQL
import WKCodable

public struct GeometricMultiLineString2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    /// The points
    public let lineStrings: [GeometricLineString2D]
    
    /// Create a new `GISGeometricMultiLineString2D`
    public init(lineStrings: [GeometricLineString2D]) {
        self.lineStrings = lineStrings
    }
    
}

extension GeometricMultiLineString2D: WKGeometryConvertible {
    /// Convertible type
    public typealias GeometryType = MultiLineString
    
    public init(geometry polygon: GeometryType) {
        let lineStrings = polygon.lineStrings.map { GeometricLineString2D(geometry: $0) }
        self.init(lineStrings: lineStrings)
    }
    
    public var geometry: GeometryType {
        let lineStrings = self.lineStrings.map { $0.geometry }
        return .init(lineStrings: lineStrings, srid: FluentPostGISSrid)
    }
}

extension GeometricMultiLineString2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricMultiLineString2D, GeometricMultiLineString2D) {
        return (.init(lineStrings: []),
                .init(lineStrings: [ GeometricLineString2D(points: [GeometricPoint2D(x: 0, y: 0)]) ]))
    }
}
