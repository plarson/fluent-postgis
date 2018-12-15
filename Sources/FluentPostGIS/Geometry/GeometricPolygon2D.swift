import Foundation
import PostgreSQL
import WKCodable

public struct GeometricPolygon2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    /// The points
    public let exteriorRing: GeometricLineString2D
    public let interiorRings: [GeometricLineString2D]
    
    public init(exteriorRing: GeometricLineString2D) {
        self.init(exteriorRing: exteriorRing, interiorRings: [])
    }

    /// Create a new `GISGeometricPolygon2D`
    public init(exteriorRing: GeometricLineString2D, interiorRings: [GeometricLineString2D]) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
    }
    
}

extension GeometricPolygon2D: GeometryConvertible {
    
    /// Convertible type
    public typealias GeometryType = WKCodable.Polygon

    public init(geometry polygon: GeometryType) {
        let exteriorRing = GeometricLineString2D(geometry: polygon.exteriorRing)
        let interiorRings = polygon.interiorRings.map { GeometricLineString2D(geometry: $0) }
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings)
    }

    public var geometry: GeometryType {
        let exteriorRing = self.exteriorRing.geometry
        let interiorRings = self.interiorRings.map { $0.geometry }
        return .init(exteriorRing: exteriorRing, interiorRings: interiorRings, srid: FluentPostGISSrid)
    }
}

extension GeometricPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {

    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricPolygon }

    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricPolygon2D, GeometricPolygon2D) {
        return (.init(exteriorRing: GeometricLineString2D(points: []), interiorRings: []),
                .init(exteriorRing: GeometricLineString2D(points: [GeometricPoint2D(x: 0, y: 0)]), interiorRings: []))
    }
}
