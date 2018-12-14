import Foundation
import PostgreSQL
import WKCodable

public struct GeographicPolygon2D: Codable, Equatable, PostGISGeometry {
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
    
    public init(wkbGeometry polygon: WKBPolygon) {
        let exteriorRing = GeographicLineString2D(wkbGeometry: polygon.exteriorRing)
        let interiorRings = polygon.interiorRings.map { GeographicLineString2D(wkbGeometry: $0) }
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings)
    }
    
    public var wkbGeometry: WKBGeometry {
        let exteriorRing = self.exteriorRing.wkbGeometry as! WKBLineString
        let interiorRings = self.interiorRings.map { $0.wkbGeometry as! WKBLineString }
        return WKBPolygon(exteriorRing: exteriorRing, interiorRings: interiorRings, srid: FluentPostGISSrid)
    }
}

extension GeographicPolygon2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeographicPolygon2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeographicPolygon2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBPolygon
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

extension GeographicPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicPolygon }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicPolygon2D, GeographicPolygon2D) {
        return (.init(exteriorRing: GeographicLineString2D(points: []), interiorRings: []),
                .init(exteriorRing: GeographicLineString2D(points: [GeographicPoint2D(longitude: 0, latitude: 0)]), interiorRings: []))
    }
}
