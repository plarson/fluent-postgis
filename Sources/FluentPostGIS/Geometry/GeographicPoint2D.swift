import Foundation
import PostgreSQL
import WKCodable

public struct GeographicPoint2D: Codable, Equatable, PostGISGeometry {
    /// The point's x coordinate.
    public var longitude: Double
    
    /// The point's y coordinate.
    public var latitude: Double
    
    /// Create a new `GISGeographicPoint2D`
    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    public init(wkbGeometry point: WKBPoint) {
        self.init(longitude: point.x, latitude: point.y)
    }
    
    public var wkbGeometry: WKBGeometry {
        return WKBPoint(vector: [self.longitude, self.latitude], srid: FluentPostGISSrid)
    }
}

extension GeographicPoint2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeographicPoint2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeographicPoint2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let point = try decoder.decode(from: value) as! WKBPoint
            return .init(wkbGeometry: point)
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

extension GeographicPoint2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicPoint2D, GeographicPoint2D) {
        return (.init(longitude: 0, latitude: 0), .init(longitude: 1, latitude: 1))
    }
}
