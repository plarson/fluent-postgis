import Foundation
import PostgreSQL
import WKCodable

public struct GeometricLineString2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    /// The points
    public var points: [GeometricPoint2D]
    
    /// Create a new `GISGeometricLineString2D`
    public init(points: [GeometricPoint2D]) {
        self.points = points
    }
    
}

extension GeometricLineString2D: GeometryConvertible {
    /// Convertible type
    public typealias GeometryType = LineString
    
    public init(geometry lineString: GeometryType) {
        let points = lineString.points.map { GeometricPoint2D(geometry: $0) }
        self.init(points: points)
    }
    
    public var geometry: GeometryType {
        return .init(points: self.points.map { $0.geometry }, srid: FluentPostGISSrid)
    }
}

extension GeometricLineString2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricLineString2D, GeometricLineString2D) {
        return (.init(points: [GeometricPoint2D(x: 0, y: 0)]), .init(points: []))
    }
}
