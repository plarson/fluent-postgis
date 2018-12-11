import Foundation
import PostgreSQL
import WKCodable

public struct GISGeographicGeometryCollection2D: Codable, Equatable, GISGeometry {
   
    /// The points
    public let geometries: [GISGeometry]
    
    /// Create a new `GISGeographicGeometryCollection2D`
    public init(geometries: [GISGeometry]) {
        self.geometries = geometries
    }
    
    public init(wkbGeometry: WKBGeometryCollection) {
        geometries = wkbGeometry.geometries.map {
            if let value = $0 as? WKBPoint {
                return GISGeographicPoint2D(wkbGeometry: value)
            } else if let value = $0 as? WKBLineString {
                return GISGeographicLineString2D(wkbGeometry: value)
            } else if let value = $0 as? WKBPolygon {
                return GISGeographicPolygon2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiPoint {
                return GISGeographicMultiPoint2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiLineString {
                return GISGeographicMultiLineString2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiPolygon {
                return GISGeographicMultiPolygon2D(wkbGeometry: value)
            } else if let value = $0 as? WKBGeometryCollection {
                return GISGeographicGeometryCollection2D(wkbGeometry: value)
            } else {
                assertionFailure()
                return GISGeographicPoint2D(longitude: 0, latitude: 0)
            }
        }
    }
    
    public var wkbGeometry: WKBGeometry {
        let geometries = self.geometries.map { $0.wkbGeometry }
        return WKBGeometryCollection(geometries: geometries, srid: FluentPostGISSrid)
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        let wkbGeometry = try WKTDecoder().decode(from: value) as! WKBGeometryCollection
        self.init(wkbGeometry: wkbGeometry)
    }
    
    public func encode(to encoder: Encoder) throws {
        let wktEncoder = WKTEncoder()
        let value = wktEncoder.encode(wkbGeometry)
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    public static func == (lhs: GISGeographicGeometryCollection2D, rhs: GISGeographicGeometryCollection2D) -> Bool {
        guard lhs.geometries.count == rhs.geometries.count else {
            return false
        }
        for i in 0..<lhs.geometries.count {
            guard lhs.geometries[i].isEqual(to: rhs.geometries[i]) else {
                return false
            }
        }
        return true
    }
}

extension GISGeographicGeometryCollection2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeographicGeometryCollection2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeographicGeometryCollection2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBGeometryCollection
            return .init(wkbGeometry: geometry)
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

extension GISGeographicGeometryCollection2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicGeometryCollection }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeographicGeometryCollection2D, GISGeographicGeometryCollection2D) {
        return (.init(geometries: []),
                .init(geometries: [ GISGeographicPolygon2D(exteriorRing: GISGeographicLineString2D(points: [GISGeographicPoint2D(longitude: 0, latitude: 0)]))]))
    }
}
