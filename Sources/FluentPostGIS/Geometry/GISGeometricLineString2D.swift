import Foundation
import PostgreSQL
import WKCodable

public struct GISGeometricLineString2D: Codable, Equatable, GISGeometry {
    /// The points
    public var points: [GISGeometricPoint2D]
    
    /// Create a new `GISGeometricLineString2D`
    public init(points: [GISGeometricPoint2D]) {
        self.points = points
    }
    
    public init(wkbGeometry lineString: WKBLineString) {
        let points = lineString.points.map { GISGeometricPoint2D(wkbGeometry: $0) }
        self.init(points: points)
    }
    
    public var wkbGeometry: WKBGeometry {
        return WKBLineString(points: self.points.map { $0.wkbGeometry as! WKBPoint }, srid: FluentPostGISSrid)
    }
}

extension GISGeometricLineString2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeometricLineString2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeometricLineString2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBLineString
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

extension GISGeometricLineString2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricLineString }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeometricLineString2D, GISGeometricLineString2D) {
        return (.init(points: [GISGeometricPoint2D(x: 0, y: 0)]), .init(points: []))
    }
}
