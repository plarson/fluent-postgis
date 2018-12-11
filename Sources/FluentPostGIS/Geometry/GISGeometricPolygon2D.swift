import Foundation
import PostgreSQL
import WKCodable

public struct GISGeometricPolygon2D: Codable, Equatable, GISGeometry {
    /// The points
    public let exteriorRing: GISGeometricLineString2D
    public let interiorRings: [GISGeometricLineString2D]
    
    public init(exteriorRing: GISGeometricLineString2D) {
        self.init(exteriorRing: exteriorRing, interiorRings: [])
    }

    /// Create a new `GISGeometricPolygon2D`
    public init(exteriorRing: GISGeometricLineString2D, interiorRings: [GISGeometricLineString2D]) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
    }

    public init(wkbGeometry polygon: WKBPolygon) {
        let exteriorRing = GISGeometricLineString2D(wkbGeometry: polygon.exteriorRing)
        let interiorRings = polygon.interiorRings.map { GISGeometricLineString2D(wkbGeometry: $0) }
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings)
    }

    public var wkbGeometry: WKBGeometry {
        let exteriorRing = self.exteriorRing.wkbGeometry as! WKBLineString
        let interiorRings = self.interiorRings.map { $0.wkbGeometry as! WKBLineString }
        return WKBPolygon(exteriorRing: exteriorRing, interiorRings: interiorRings, srid: FluentPostGISSrid)
    }
}

extension GISGeometricPolygon2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeometricPolygon2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeometricPolygon2D {
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

extension GISGeometricPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {

    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricPolygon }

    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeometricPolygon2D, GISGeometricPolygon2D) {
        return (.init(exteriorRing: GISGeometricLineString2D(points: []), interiorRings: []),
                .init(exteriorRing: GISGeometricLineString2D(points: [GISGeometricPoint2D(x: 0, y: 0)]), interiorRings: []))
    }
}
