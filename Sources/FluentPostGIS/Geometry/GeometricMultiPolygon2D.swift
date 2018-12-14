import Foundation
import PostgreSQL
import WKCodable

public struct GeometricMultiPolygon2D: Codable, Equatable, PostGISGeometry {
    /// The points
    public let polygons: [GeometricPolygon2D]
    
    /// Create a new `GISGeometricMultiPolygon2D`
    public init(polygons: [GeometricPolygon2D]) {
        self.polygons = polygons
    }
    
    public init(wkbGeometry polygon: WKBMultiPolygon) {
        let polygons = polygon.polygons.map { GeometricPolygon2D(wkbGeometry: $0) }
        self.init(polygons: polygons)
    }
    
    public var wkbGeometry: WKBGeometry {
        let polygons = self.polygons.map { $0.wkbGeometry as! WKBPolygon }
        return WKBMultiPolygon(polygons: polygons, srid: FluentPostGISSrid)
    }
}

extension GeometricMultiPolygon2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeometricMultiPolygon2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeometricMultiPolygon2D {
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

extension GeometricMultiPolygon2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricMultiPolygon2D, GeometricMultiPolygon2D) {
        return (.init(polygons: []),
                .init(polygons: [ GeometricPolygon2D(exteriorRing: GeometricLineString2D(points: [GeometricPoint2D(x: 0, y: 0)]))]))
    }
}
