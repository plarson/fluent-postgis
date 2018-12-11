import Foundation
import PostgreSQL
import WKCodable

public struct GISGeographicPolygon2D: Codable, Equatable, GISGeometry {
    /// The points
    public let exteriorRing: GISGeographicLineString2D
    public let interiorRings: [GISGeographicLineString2D]
    
    /// Create a new `GISGeographicPolygon2D`
    public init(exteriorRing: GISGeographicLineString2D, interiorRings: [GISGeographicLineString2D]) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
    }
    
    public static func from(_ polygon: WKBPolygon) -> GISGeographicPolygon2D {
        let exteriorRing = GISGeographicLineString2D.from(polygon.exteriorRing)
        let interiorRings = polygon.interiorRings.map { GISGeographicLineString2D.from($0) }
        return GISGeographicPolygon2D(exteriorRing: exteriorRing, interiorRings: interiorRings)
    }
    
    public var wkbGeometry: WKBGeometry {
        let exteriorRing = self.exteriorRing.wkbGeometry as! WKBLineString
        let interiorRings = self.interiorRings.map { $0.wkbGeometry as! WKBLineString }
        return WKBPolygon(exteriorRing: exteriorRing, interiorRings: interiorRings, srid: FluentPostGISSrid)
    }
}

extension GISGeographicPolygon2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeographicPolygon2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeographicPolygon2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBPolygon
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

extension GISGeographicPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicPolygon }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeographicPolygon2D, GISGeographicPolygon2D) {
        return (.init(exteriorRing: GISGeographicLineString2D(points: []), interiorRings: []),
                .init(exteriorRing: GISGeographicLineString2D(points: []), interiorRings: []))
    }
}
