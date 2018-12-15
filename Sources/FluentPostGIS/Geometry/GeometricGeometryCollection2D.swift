import Foundation
import PostgreSQL
import WKCodable

public struct GeometricGeometryCollection2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    
    /// The points
    public let geometries: [AnyGeometryConvertible]
    
    /// Create a new `GISGeometricGeometryCollection2D`
    public init(geometries: [Any]) {
        self.geometries = []
    }
    
}

extension GeometricGeometryCollection2D: WKGeometryConvertible {
    public typealias GeometryType = GeometryCollection    
    
    public init(geometry: GeometryType) {
        geometries = geometry.geometries.map {
            if let value = $0 as? Point {
                return AnyGeometryConvertible(GeometricPoint2D(geometry: value))
            } else if let value = $0 as? LineString {
                return AnyGeometryConvertible(GeometricLineString2D(geometry: value))
            } else if let value = $0 as? WKCodable.Polygon {
                return AnyGeometryConvertible(GeometricPolygon2D(geometry: value))
            } else if let value = $0 as? MultiPoint {
                return AnyGeometryConvertible(GeometricMultiPoint2D(geometry: value))
            } else if let value = $0 as? MultiLineString {
                return AnyGeometryConvertible(GeometricMultiLineString2D(geometry: value))
            } else if let value = $0 as? MultiPolygon {
                return AnyGeometryConvertible(GeometricMultiPolygon2D(geometry: value))
            } else if let value = $0 as? GeometryCollection {
                return AnyGeometryConvertible(GeometricGeometryCollection2D(geometry: value))
            } else {
                assertionFailure()
                return AnyGeometryConvertible(GeometricPoint2D(x: 0, y: 0))
            }
        }
    }
    
    public var geometry: GeometryType {
        let geometries = self.geometries.map { $0.wkbGeometry }
        return .init(geometries: geometries, srid: FluentPostGISSrid)
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        let wkbGeometry: GeometryCollection = try WKTDecoder().decode(from: value)
        self.init(geometry: wkbGeometry)
    }
    
    public func encode(to encoder: Encoder) throws {
        let wktEncoder = WKTEncoder()
        let value = wktEncoder.encode(geometry)
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

extension GeometricGeometryCollection2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricGeometryCollection }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricGeometryCollection2D, GeometricGeometryCollection2D) {
        return (.init(geometries: []),
                .init(geometries: [ AnyGeometryConvertible(GeometricPolygon2D(exteriorRing: GeometricLineString2D(points: [GeometricPoint2D(x: 0, y: 0)])))]))
    }
}
