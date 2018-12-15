import Foundation
import PostgreSQL
import WKCodable

public struct GeographicMultiLineString2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    /// The points
    public let lineStrings: [GeographicLineString2D]
    
    /// Create a new `GISGeographicMultiLineString2D`
    public init(lineStrings: [GeographicLineString2D]) {
        self.lineStrings = lineStrings
    }
}

extension GeographicMultiLineString2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = MultiLineString
    
    public init(geometry polygon: GeometryType) {
        let lineStrings = polygon.lineStrings.map { GeographicLineString2D(geometry: $0) }
        self.init(lineStrings: lineStrings)
    }
    
    public var geometry: GeometryType {
        let lineStrings = self.lineStrings.map { $0.geometry }
        return .init(lineStrings: lineStrings, srid: FluentPostGISSrid)
    }
    
    public var baseGeometry: Geometry {
        return self.geometry
    }
}

extension GeographicMultiLineString2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicMultiLineString2D, GeographicMultiLineString2D) {
        return (.init(lineStrings: []),
                .init(lineStrings: [ GeographicLineString2D(points: [GeographicPoint2D(longitude: 0, latitude: 0)]) ]))
    }
}
