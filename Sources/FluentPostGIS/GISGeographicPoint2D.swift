import Foundation
import PostgreSQL
import WKCodable

public struct GISGeographicPoint2D: Codable, Equatable, GISGeometry {
    /// The point's x coordinate.
    public var longitude: Double
    
    /// The point's y coordinate.
    public var latitude: Double
    
    /// Create a new `GISGeographicPoint2D`
    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    public var wkbGeometry: WKBGeometry {
        return WKBPoint(vector: [self.longitude, self.latitude], srid: FluentPostGISSrid)
    }
}

extension GISGeographicPoint2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeographicPoint2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeographicPoint2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let point = try decoder.decode(from: value) as! WKBPoint
            return .init(longitude: point.x, latitude: point.y)
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

extension GISGeographicPoint2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeographicPoint2D, GISGeographicPoint2D) {
        return (.init(longitude: 0, latitude: 0), .init(longitude: 1, latitude: 1))
    }
}
