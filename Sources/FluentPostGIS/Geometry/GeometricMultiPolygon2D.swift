import Foundation
import PostgreSQL
import WKCodable

public struct GeometricMultiPolygon2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    /// The points
    public let polygons: [GeometricPolygon2D]
    
    /// Create a new `GISGeometricMultiPolygon2D`
    public init(polygons: [GeometricPolygon2D]) {
        self.polygons = polygons
    }
}

extension GeometricMultiPolygon2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = MultiPolygon
    
    public init(geometry polygon: GeometryType) {
        let polygons = polygon.polygons.map { GeometricPolygon2D(geometry: $0) }
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

extension GeometricMultiPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricMultiPolygon2D, GeometricMultiPolygon2D) {
        return (.init(polygons: []),
                .init(polygons: [ GeometricPolygon2D(exteriorRing: GeometricLineString2D(points: [GeometricPoint2D(x: 0, y: 0)]))]))
    }
}
