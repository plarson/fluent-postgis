import Foundation
import PostgreSQL
import WKCodable

public struct GeometricGeometryCollection2D: Codable, Equatable, PostGISGeometry {
    
    /// The points
    public let geometries: [PostGISGeometry]
    
    /// Create a new `GISGeometricGeometryCollection2D`
    public init(geometries: [PostGISGeometry]) {
        self.geometries = geometries
    }
    
    public init(wkbGeometry: WKBGeometryCollection) {
        geometries = wkbGeometry.geometries.map {
            if let value = $0 as? WKBPoint {
                return GeometricPoint2D(wkbGeometry: value)
            } else if let value = $0 as? WKBLineString {
                return GeometricLineString2D(wkbGeometry: value)
            } else if let value = $0 as? WKBPolygon {
                return GeometricPolygon2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiPoint {
                return GeometricMultiPoint2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiLineString {
                return GeometricMultiLineString2D(wkbGeometry: value)
            } else if let value = $0 as? WKBMultiPolygon {
                return GeometricMultiPolygon2D(wkbGeometry: value)
            } else if let value = $0 as? WKBGeometryCollection {
                return GeometricGeometryCollection2D(wkbGeometry: value)
            } else {
                assertionFailure()
                return GeometricPoint2D(x: 0, y: 0)
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
    
    public static func == (lhs: GeometricGeometryCollection2D, rhs: GeometricGeometryCollection2D) -> Bool {
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

extension GeometricGeometryCollection2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeometricGeometryCollection2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeometricGeometryCollection2D {
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

extension GeometricGeometryCollection2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricGeometryCollection }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricGeometryCollection2D, GeometricGeometryCollection2D) {
        return (.init(geometries: []),
                .init(geometries: [ GeometricPolygon2D(exteriorRing: GeometricLineString2D(points: [GeometricPoint2D(x: 0, y: 0)]))]))
    }
}
