import Foundation
import PostgreSQL
import WKCodable

public struct GeometricMultiPoint2D: Codable, Equatable, PostGISGeometry {
    /// The points
    public var points: [GeometricPoint2D]
    
    /// Create a new `GISGeometricLineString2D`
    public init(points: [GeometricPoint2D]) {
        self.points = points
    }
    
    public init(wkbGeometry lineString: WKBMultiPoint) {
        let points = lineString.points.map { GeometricPoint2D(wkbGeometry: $0) }
        self.init(points: points)
    }
    
    public var wkbGeometry: WKBGeometry {
        return WKBMultiPoint(points: self.points.map { $0.wkbGeometry as! WKBPoint }, srid: FluentPostGISSrid)
    }
}

extension GeometricMultiPoint2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeometricMultiPoint2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeometricMultiPoint2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBMultiPoint
            return self.init(wkbGeometry: geometry)
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

extension GeometricMultiPoint2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricMultiPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricMultiPoint2D, GeometricMultiPoint2D) {
        return (.init(points: []), .init(points: [GeometricPoint2D(x: 0, y: 0)]))
    }
}
