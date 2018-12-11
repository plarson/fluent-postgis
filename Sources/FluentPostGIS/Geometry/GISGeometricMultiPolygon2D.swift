import Foundation
import PostgreSQL
import WKCodable

public struct GISGeometricMultiPolygon2D: Codable, Equatable, GISGeometry {
    /// The points
    public let polygons: [GISGeometricPolygon2D]
    
    /// Create a new `GISGeometricMultiPolygon2D`
    public init(polygons: [GISGeometricPolygon2D]) {
        self.polygons = polygons
    }
    
    public init(wkbGeometry polygon: WKBMultiPolygon) {
        let polygons = polygon.polygons.map { GISGeometricPolygon2D(wkbGeometry: $0) }
        self.init(polygons: polygons)
    }
    
    public var wkbGeometry: WKBGeometry {
        let polygons = self.polygons.map { $0.wkbGeometry as! WKBPolygon }
        return WKBMultiPolygon(polygons: polygons, srid: FluentPostGISSrid)
    }
}

extension GISGeometricMultiPolygon2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeometricMultiPolygon2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeometricMultiPolygon2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBMultiPolygon
            return self.init(wkbGeometry: geometry)
        } else {
            throw PostGISError.decode(self, from: data)
        }
    }
    
    public func convertToPostgreSQLData() throws -> PostgreSQLData {
        let encoder = WKBEncoder(byteOrder: .littleEndian)
        let data = encoder.encode(wkbGeometry)
        return PostgreSQLData(.geometry, binary: data)
    }
}

extension GISGeometricMultiPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeometricMultiPolygon2D, GISGeometricMultiPolygon2D) {
        return (.init(polygons: []),
                .init(polygons: [ GISGeometricPolygon2D(exteriorRing: GISGeometricLineString2D(points: [GISGeometricPoint2D(x: 0, y: 0)]))]))
    }
}
