import Foundation
import PostgreSQL
import WKCodable

public struct GeometricMultiLineString2D: Codable, Equatable, PostGISGeometry {
    /// The points
    public let lineStrings: [GeometricLineString2D]
    
    /// Create a new `GISGeometricMultiLineString2D`
    public init(lineStrings: [GeometricLineString2D]) {
        self.lineStrings = lineStrings
    }
    
    public init(wkbGeometry polygon: WKBMultiLineString) {
        let lineStrings = polygon.lineStrings.map { GeometricLineString2D(wkbGeometry: $0) }
        self.init(lineStrings: lineStrings)
    }
    
    public var wkbGeometry: WKBGeometry {
        let lineStrings = self.lineStrings.map { $0.wkbGeometry as! WKBLineString }
        return WKBMultiLineString(lineStrings: lineStrings, srid: FluentPostGISSrid)
    }
}

extension GeometricMultiLineString2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeometricMultiLineString2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeometricMultiLineString2D {
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

extension GeometricMultiLineString2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricMultiLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeometricMultiLineString2D, GeometricMultiLineString2D) {
        return (.init(lineStrings: []),
                .init(lineStrings: [ GeometricLineString2D(points: [GeometricPoint2D(x: 0, y: 0)]) ]))
    }
}
