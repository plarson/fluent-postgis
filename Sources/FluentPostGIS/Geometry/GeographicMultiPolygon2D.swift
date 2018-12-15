import Foundation
import PostgreSQL
import WKCodable

public struct GeographicMultiPolygon2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible  {
    /// The points
    public let polygons: [GeographicPolygon2D]
    
    /// Create a new `GISGeographicMultiPolygon2D`
    public init(polygons: [GeographicPolygon2D]) {
        self.polygons = polygons
    }
}

extension GeographicMultiPolygon2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = MultiPolygon
    
    public init(geometry polygon: GeometryType) {
        let polygons = polygon.polygons.map { GeographicPolygon2D(geometry: $0) }
        self.init(polygons: polygons)
    }
    
    public var geometry: GeometryType {
        let polygons = self.polygons.map { $0.geometry }
        return .init(polygons: polygons, srid: FluentPostGISSrid)
    }
    
    public var baseGeometry: Geometry {
        return self.geometry
    }
}

extension GeographicMultiPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicMultiPolygon2D, GeographicMultiPolygon2D) {
        return (.init(polygons: []),
                .init(polygons: [ GeographicPolygon2D(exteriorRing: GeographicLineString2D(points: [GeographicPoint2D(longitude: 0, latitude: 0)]))]))
    }
}
