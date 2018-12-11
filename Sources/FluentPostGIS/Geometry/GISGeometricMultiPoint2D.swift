import Foundation
import PostgreSQL
import WKCodable

public struct GISGeometricMultiPoint2D: Codable, Equatable, GISGeometry {
    /// The points
    public var points: [GISGeometricPoint2D]
    
    /// Create a new `GISGeometricLineString2D`
    public init(points: [GISGeometricPoint2D]) {
        self.points = points
    }
    
    public static func from(_ lineString: WKBMultiPoint) -> GISGeometricMultiPoint2D {
        let points = lineString.points.map { GISGeometricPoint2D.from($0) }
        return GISGeometricMultiPoint2D(points: points)
    }
    
    public var wkbGeometry: WKBGeometry {
        return WKBMultiPoint(points: self.points.map { $0.wkbGeometry as! WKBPoint }, srid: FluentPostGISSrid)
    }
}

extension GISGeometricMultiPoint2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GISGeometricMultiPoint2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GISGeometricMultiPoint2D {
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

extension GISGeometricMultiPoint2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geometricMultiPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GISGeometricMultiPoint2D, GISGeometricMultiPoint2D) {
        return (.init(points: []), .init(points: [GISGeometricPoint2D(x: 0, y: 0)]))
    }
}
