import Foundation
import PostgreSQL
import WKCodable

public struct GISGeographicLineString2D: Codable, Equatable, GISGeometry {
    /// The points
    public var points: [GISGeographicPoint2D]
    
    /// Create a new `GISGeographicLineString2D`
    public init(points: [GISGeographicPoint2D]) {
        self.points = points
    }
    
    public static func from(_ lineString: WKBLineString) -> GISGeographicLineString2D {
        let points = lineString.points.map { GISGeographicPoint2D.from($0) }
        return GISGeographicLineString2D(points: points)
    }
    
    public var wkbGeometry: WKBGeometry {
        return WKBLineString(points: self.points.map { $0.wkbGeometry as! WKBPoint }, srid: FluentPostGISSrid)
    }
}

extension GISGeographicLineString2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeographicLineString2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeographicLineString2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBLineString
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

extension GISGeographicLineString2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeographicLineString2D, GISGeographicLineString2D) {
        return (.init(points: []), .init(points: [GISGeographicPoint2D(longitude: 0, latitude: 0)]))
    }
}
