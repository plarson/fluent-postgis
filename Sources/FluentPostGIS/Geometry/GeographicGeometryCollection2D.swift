import Foundation
import PostgreSQL
import WKCodable

public struct GeographicGeometryCollection2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible  {
   
    /// The points
    public let geometries: [Geometry]

    /// Create a new `GISGeographicGeometryCollection2D`
    public init(geometries: [Geometry]) {
        self.geometries = geometries
    }

}

extension GeographicGeometryCollection2D: GeometryConvertible {
    /// Convertible type
    public typealias GeometryType = GeometryCollection
    
    public init(geometry: GeometryCollection) {
        geometries = geometry.geometries
    }
    
    public var geometry: GeometryCollection {
        return .init(geometries: self.geometries, srid: FluentPostGISSrid)
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

extension GeographicGeometryCollection2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicGeometryCollection }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicGeometryCollection2D, GeographicGeometryCollection2D) {
        return (.init(geometries: []),
                .init(geometries: [ Polygon(exteriorRing: LineString(points: [Point(vector:[0,0])]))]))
    }
}
