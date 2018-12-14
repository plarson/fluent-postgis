import Foundation
import PostgreSQL
import WKCodable

public struct GeographicMultiPolygon2D: Codable, Equatable, PostGISGeometry {
    /// The points
    public let polygons: [GeographicPolygon2D]
    
    /// Create a new `GISGeographicMultiPolygon2D`
    public init(polygons: [GeographicPolygon2D]) {
        self.polygons = polygons
    }
    
    public init(wkbGeometry polygon: WKBMultiPolygon) {
        let polygons = polygon.polygons.map { GeographicPolygon2D(wkbGeometry: $0) }
        self.init(polygons: polygons)
    }
    
    public var wkbGeometry: WKBGeometry {
        let polygons = self.polygons.map { $0.wkbGeometry as! WKBPolygon }
        return WKBMultiPolygon(polygons: polygons, srid: FluentPostGISSrid)
    }
}

extension GeographicMultiPolygon2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeographicMultiPolygon2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeographicMultiPolygon2D {
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

extension GeographicMultiPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicMultiPolygon2D, GeographicMultiPolygon2D) {
        return (.init(polygons: []),
                .init(polygons: [ GeographicPolygon2D(exteriorRing: GeographicLineString2D(points: [GeographicPoint2D(longitude: 0, latitude: 0)]))]))
    }
}
