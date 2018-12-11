import Foundation
import PostgreSQL
import WKCodable

public struct GISGeometricGeometryCollection2D: Codable, Equatable, GISGeometry {
    
    /// The points
    public let geometries: [GISGeometry]
    
    /// Create a new `GISGeometricGeometryCollection2D`
    public init(geometries: [GISGeometry]) {
        self.geometries = geometries
    }
    
    public init(wkbGeometry: WKBGeometryCollection) {
        geometries = wkbGeometry.geometries.map {
            if let value = $0 as? WKBPoint {
                return GISGeometricPoint2D(wkbGeometry: value)
            } else if let value = $0 as? WKBLineString {
                return GISGeometricLineString2D(wkbGeometry: value)
            } else if let value = $0 as? WKBPolygon {
                return GISGeometricPolygon2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiPoint {
                return GISGeometricMultiPoint2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiLineString {
                return GISGeometricMultiLineString2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiPolygon {
                return GISGeometricMultiPolygon2D(wkbGeometry: value)
            } else if let value = $0 as? WKBGeometryCollection {
                return GISGeometricGeometryCollection2D(wkbGeometry: value)
            } else {
                assertionFailure()
                return GISGeometricPoint2D(x: 0, y: 0)
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
    
    public static func == (lhs: GISGeometricGeometryCollection2D, rhs: GISGeometricGeometryCollection2D) -> Bool {
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

extension GISGeometricGeometryCollection2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeometricGeometryCollection2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeometricGeometryCollection2D {
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

extension GISGeometricGeometryCollection2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricGeometryCollection }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeometricGeometryCollection2D, GISGeometricGeometryCollection2D) {
        return (.init(geometries: []),
                .init(geometries: [ GISGeometricPolygon2D(exteriorRing: GISGeometricLineString2D(points: [GISGeometricPoint2D(x: 0, y: 0)]))]))
    }
}
