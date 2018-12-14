import Foundation
import PostgreSQL
import WKCodable

public struct GeographicMultiLineString2D: Codable, Equatable, PostGISGeometry {
    /// The points
    public let lineStrings: [GeographicLineString2D]
    
    /// Create a new `GISGeographicMultiLineString2D`
    public init(lineStrings: [GeographicLineString2D]) {
        self.lineStrings = lineStrings
    }
    
    public init(wkbGeometry polygon: WKBMultiLineString) {
        let lineStrings = polygon.lineStrings.map { GeographicLineString2D(wkbGeometry: $0) }
        self.init(lineStrings: lineStrings)
    }
    
    public var wkbGeometry: WKBGeometry {
        let lineStrings = self.lineStrings.map { $0.wkbGeometry as! WKBLineString }
        return WKBMultiLineString(lineStrings: lineStrings, srid: FluentPostGISSrid)
    }
}

extension GeographicMultiLineString2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeographicMultiLineString2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeographicMultiLineString2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBMultiLineString
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

extension GeographicMultiLineString2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicMultiLineString2D, GeographicMultiLineString2D) {
        return (.init(lineStrings: []),
                .init(lineStrings: [ GeographicLineString2D(points: [GeographicPoint2D(longitude: 0, latitude: 0)]) ]))
    }
}
