import Foundation
import PostgreSQL
import WKCodable

public struct GISGeographicMultiPolygon2D: Codable, Equatable, GISGeometry {
    /// The points
    public let polygons: [GISGeographicPolygon2D]
    
    /// Create a new `GISGeographicMultiPolygon2D`
    public init(polygons: [GISGeographicPolygon2D]) {
        self.polygons = polygons
    }
    
    public static func from(_ polygon: WKBMultiPolygon) -> GISGeographicMultiPolygon2D {
        let polygons = polygon.polygons.map { GISGeographicPolygon2D.from($0) }
        return GISGeographicMultiPolygon2D(polygons: polygons)
    }
    
    public var wkbGeometry: WKBGeometry {
        let polygons = self.polygons.map { $0.wkbGeometry as! WKBPolygon }
        return WKBMultiPolygon(polygons: polygons, srid: FluentPostGISSrid)
    }
}

extension GISGeographicMultiPolygon2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeographicMultiPolygon2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeographicMultiPolygon2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBMultiPolygon
            return .from(geometry)
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

extension GISGeographicMultiPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeographicMultiPolygon2D, GISGeographicMultiPolygon2D) {
        return (.init(polygons: []),
                .init(polygons: [ GISGeographicPolygon2D(exteriorRing: GISGeographicLineString2D(points: [GISGeographicPoint2D(longitude: 0, latitude: 0)]))]))
    }
}
