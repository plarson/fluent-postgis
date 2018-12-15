import Foundation
import PostgreSQL
import WKCodable

public struct GeometricGeometryCollection2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    
    /// The points
    public let geometries: [Geometry]
    
    /// Create a new `GISGeometricGeometryCollection2D`
    public init(geometries: [Geometry]) {
        self.geometries = []
    }    
}

extension GeometricGeometryCollection2D: GeometryConvertible {
    public typealias GeometryType = GeometryCollection    
    
    public init(geometry: GeometryType) {
        geometries = geometry.geometries
    }
    
    public var geometry: GeometryType {
        return .init(geometries: self.geometries, srid: FluentPostGISSrid)
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        let geometry: GeometryCollection = try WKTDecoder().decode(from: value)
        self.init(geometry: geometry)
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
                .init(geometries: [ Polygon(exteriorRing: LineString(points: [Point(vector:[])]))]))
    }
}
