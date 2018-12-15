import Foundation
import PostgreSQL
import WKCodable

public struct GeometricPoint2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    /// The point's x coordinate.
    public var x: Double
    
    /// The point's y coordinate.
    public var y: Double
    
    /// Create a new `GISGeometricPoint2D`
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

extension GeometricPoint2D: WKGeometryConvertible {
    /// Convertible type
    public typealias GeometryType = Point

    public init(geometry point: GeometryType) {
        self.init(x: point.x, y: point.y)
    }
    
    public var geometry: GeometryType {
        return .init(vector: [self.x, self.y], srid: FluentPostGISSrid)
    }
}

extension GeometricPoint2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricPoint2D, GeometricPoint2D) {
        return (.init(x: 0, y: 0), .init(x: 1, y: 1))
    }
}
