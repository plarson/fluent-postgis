import Foundation
import PostgreSQL
import WKCodable

public struct GISGeographicMultiLineString2D: Codable, Equatable, GISGeometry {
    /// The points
    public let lineStrings: [GISGeographicLineString2D]
    
    /// Create a new `GISGeographicMultiLineString2D`
    public init(lineStrings: [GISGeographicLineString2D]) {
        self.lineStrings = lineStrings
    }
    
    public static func from(_ polygon: WKBMultiLineString) -> GISGeographicMultiLineString2D {
        let lineStrings = polygon.lineStrings.map { GISGeographicLineString2D.from($0) }
        return GISGeographicMultiLineString2D(lineStrings: lineStrings)
    }
    
    public var wkbGeometry: WKBGeometry {
        let lineStrings = self.lineStrings.map { $0.wkbGeometry as! WKBLineString }
        return WKBMultiLineString(lineStrings: lineStrings, srid: FluentPostGISSrid)
    }
}

extension GISGeographicMultiLineString2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeographicMultiLineString2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeographicMultiLineString2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBMultiLineString
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

extension GISGeographicMultiLineString2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeographicMultiLineString2D, GISGeographicMultiLineString2D) {
        return (.init(lineStrings: []),
                .init(lineStrings: [ GISGeographicLineString2D(points: [GISGeographicPoint2D(longitude: 0, latitude: 0)]) ]))
    }
}
