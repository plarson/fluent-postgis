import Foundation
import PostgreSQL
import WKCodable

public struct GeographicGeometryCollection2D: Codable, Equatable, PostGISGeometry {
   
    /// The points
    public let geometries: [PostGISGeometry]
    
    /// Create a new `GISGeographicGeometryCollection2D`
    public init(geometries: [PostGISGeometry]) {
        self.geometries = geometries
    }
    
    public init(wkbGeometry: WKBGeometryCollection) {
        geometries = wkbGeometry.geometries.map {
            if let value = $0 as? WKBPoint {
                return GeographicPoint2D(wkbGeometry: value)
            } else if let value = $0 as? WKBLineString {
                return GeographicLineString2D(wkbGeometry: value)
            } else if let value = $0 as? WKBPolygon {
                return GeographicPolygon2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiPoint {
                return GeographicMultiPoint2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiLineString {
                return GeographicMultiLineString2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiPolygon {
                return GeographicMultiPolygon2D(wkbGeometry: value)
            } else if let value = $0 as? WKBGeometryCollection {
                return GeographicGeometryCollection2D(wkbGeometry: value)
            } else {
                assertionFailure()
                return GeographicPoint2D(longitude: 0, latitude: 0)
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
    
    public static func == (lhs: GeographicGeometryCollection2D, rhs: GeographicGeometryCollection2D) -> Bool {
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

extension GeographicGeometryCollection2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeographicGeometryCollection2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeographicGeometryCollection2D {
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

extension GeographicGeometryCollection2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicGeometryCollection }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicGeometryCollection2D, GeographicGeometryCollection2D) {
        return (.init(geometries: []),
                .init(geometries: [ GeographicPolygon2D(exteriorRing: GeographicLineString2D(points: [GeographicPoint2D(longitude: 0, latitude: 0)]))]))
    }
}
