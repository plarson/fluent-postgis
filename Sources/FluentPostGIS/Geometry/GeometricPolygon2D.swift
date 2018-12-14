import Foundation
import PostgreSQL
import WKCodable

public struct GeometricPolygon2D: Codable, Equatable, PostGISGeometry {
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

    public init(wkbGeometry polygon: WKBPolygon) {
        let exteriorRing = GeometricLineString2D(wkbGeometry: polygon.exteriorRing)
        let interiorRings = polygon.interiorRings.map { GeometricLineString2D(wkbGeometry: $0) }
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings)
    }

    public var wkbGeometry: WKBGeometry {
        let exteriorRing = self.exteriorRing.wkbGeometry as! WKBLineString
        let interiorRings = self.interiorRings.map { $0.wkbGeometry as! WKBLineString }
        return WKBPolygon(exteriorRing: exteriorRing, interiorRings: interiorRings, srid: FluentPostGISSrid)
    }
}

extension GeometricPolygon2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeometricPolygon2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeometricPolygon2D {
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

extension GeometricPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {

    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricPolygon }

    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricPolygon2D, GeometricPolygon2D) {
        return (.init(exteriorRing: GeometricLineString2D(points: []), interiorRings: []),
                .init(exteriorRing: GeometricLineString2D(points: [GeometricPoint2D(x: 0, y: 0)]), interiorRings: []))
    }
}
