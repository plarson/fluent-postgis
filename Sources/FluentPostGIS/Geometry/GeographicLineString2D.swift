import Foundation
import PostgreSQL
import WKCodable

public struct GeographicLineString2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    /// The points
    public var points: [GeographicPoint2D]
    
    /// Create a new `GISGeographicLineString2D`
    public init(points: [GeographicPoint2D]) {
        self.points = points
    }
}

extension GeographicLineString2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = LineString
    
    public init(geometry lineString: GeometryType) {
        let points = lineString.points.map { GeographicPoint2D(geometry: $0) }
        self.init(points: points)
    }
    
    public var geometry: GeometryType {
        return .init(points: self.points.map { $0.geometry }, srid: FluentPostGISSrid)
    }
    
    public var baseGeometry: Geometry {
        return self.geometry
    }
}

extension GeographicLineString2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicLineString2D, GeographicLineString2D) {
        return (.init(points: []), .init(points: [GeographicPoint2D(longitude: 0, latitude: 0)]))
    }
}
