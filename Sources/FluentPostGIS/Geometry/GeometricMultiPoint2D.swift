import Foundation
import PostgreSQL
import WKCodable

public struct GeometricMultiPoint2D: Codable, Equatable, CustomStringConvertible, PostgreSQLDataConvertible {
    /// The points
    public var points: [GeometricPoint2D]
    
    /// Create a new `GISGeometricLineString2D`
    public init(points: [GeometricPoint2D]) {
        self.points = points
    }
    
}

extension GeometricMultiPoint2D: WKGeometryConvertible {
    /// Convertible type
    public typealias GeometryType = MultiPoint
    
    public init(geometry lineString: GeometryType) {
        let points = lineString.points.map { GeometricPoint2D(geometry: $0) }
        self.init(points: points)
    }
    
    public var geometry: GeometryType {
        return MultiPoint(points: self.points.map { $0.geometry }, srid: FluentPostGISSrid)
    }
}

extension GeometricMultiPoint2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricMultiPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricMultiPoint2D, GeometricMultiPoint2D) {
        return (.init(points: []), .init(points: [GeometricPoint2D(x: 0, y: 0)]))
    }
}
