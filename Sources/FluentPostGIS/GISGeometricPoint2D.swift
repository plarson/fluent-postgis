import Foundation
import PostgreSQL
import WKCodable

public struct GISGeometricPoint2D: Codable, Equatable, GISGeometry {
    /// The point's x coordinate.
    public var x: Double
    
    /// The point's y coordinate.
    public var y: Double
    
    /// Create a new `GISGeometricPoint2D`
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public static func from(_ point: WKBPoint) -> GISGeometricPoint2D {
        return .init(x: point.x, y: point.y)
    }
    
    public var wkbGeometry: WKBGeometry {
        return WKBPoint(vector: [self.x, self.y], srid: FluentPostGISSrid)
    }
}

extension GISGeometricPoint2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeometricPoint2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeometricPoint2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBPoint
            return .from(geometry)
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

extension GISGeometricPoint2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeometricPoint2D, GISGeometricPoint2D) {
        return (.init(x: 0, y: 0), .init(x: 1, y: 1))
    }
}
