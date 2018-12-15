import Foundation
import PostgreSQL
import WKCodable

public struct GeographicPolygon2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible  {
    /// The points
    public let exteriorRing: GeographicLineString2D
    public let interiorRings: [GeographicLineString2D]
    
    public init(exteriorRing: GeographicLineString2D) {
        self.init(exteriorRing: exteriorRing, interiorRings: [])
    }
    
    /// Create a new `GISGeographicPolygon2D`
    public init(exteriorRing: GeographicLineString2D, interiorRings: [GeographicLineString2D]) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
    }
}

extension GeographicPolygon2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = WKCodable.Polygon
    
    public init(geometry polygon: GeometryType) {
        let exteriorRing = GeographicLineString2D(geometry: polygon.exteriorRing)
        let interiorRings = polygon.interiorRings.map { GeographicLineString2D(geometry: $0) }
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings)
    }
    
    public var geometry: GeometryType {
        let exteriorRing = self.exteriorRing.geometry
        let interiorRings = self.interiorRings.map { $0.geometry }
        return .init(exteriorRing: exteriorRing, interiorRings: interiorRings, srid: FluentPostGISSrid)
    }
    
    public var baseGeometry: Geometry {
        return self.geometry
    }
}

extension GeographicPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicPolygon }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicPolygon2D, GeographicPolygon2D) {
        return (.init(exteriorRing: GeographicLineString2D(points: []), interiorRings: []),
                .init(exteriorRing: GeographicLineString2D(points: [GeographicPoint2D(longitude: 0, latitude: 0)]), interiorRings: []))
    }
}
