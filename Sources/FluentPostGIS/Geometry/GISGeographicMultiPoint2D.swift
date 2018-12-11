import Foundation
import PostgreSQL
import WKCodable

public struct GISGeographicMultiPoint2D: Codable, Equatable, GISGeometry {
    /// The points
    public var points: [GISGeographicPoint2D]
    
    /// Create a new `GISGeographicLineString2D`
    public init(points: [GISGeographicPoint2D]) {
        self.points = points
    }
    
    public static func from(_ lineString: WKBMultiPoint) -> GISGeographicMultiPoint2D {
        let points = lineString.points.map { GISGeographicPoint2D.from($0) }
        return GISGeographicMultiPoint2D(points: points)
    }
    
    public var wkbGeometry: WKBGeometry {
        return WKBMultiPoint(points: self.points.map { $0.wkbGeometry as! WKBPoint }, srid: FluentPostGISSrid)
    }
}

extension GISGeographicMultiPoint2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeographicMultiPoint2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeographicMultiPoint2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBMultiPoint
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

extension GISGeographicMultiPoint2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicMultiPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeographicMultiPoint2D, GISGeographicMultiPoint2D) {
        return (.init(points: []), .init(points: [GISGeographicPoint2D(longitude: 0, latitude: 0)]))
    }
}
