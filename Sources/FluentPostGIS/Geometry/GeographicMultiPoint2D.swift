import Foundation
import PostgreSQL
import WKCodable

public struct GeographicMultiPoint2D: Codable, Equatable, PostGISGeometry {
    /// The points
    public var points: [GeographicPoint2D]
    
    /// Create a new `GISGeographicLineString2D`
    public init(points: [GeographicPoint2D]) {
        self.points = points
    }
    
    public init(wkbGeometry lineString: WKBMultiPoint) {
        let points = lineString.points.map { GeographicPoint2D(wkbGeometry: $0) }
        self.init(points: points)
    }
    
    public var wkbGeometry: WKBGeometry {
        return WKBMultiPoint(points: self.points.map { $0.wkbGeometry as! WKBPoint }, srid: FluentPostGISSrid)
    }
}

extension GeographicMultiPoint2D: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(wkbGeometry)
    }
}

extension GeographicMultiPoint2D: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> GeographicMultiPoint2D {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry = try decoder.decode(from: value) as! WKBMultiPoint
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

extension GeographicMultiPoint2D: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
    
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .geographicMultiPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (GeographicMultiPoint2D, GeographicMultiPoint2D) {
        return (.init(points: []), .init(points: [GeographicPoint2D(longitude: 0, latitude: 0)]))
    }
}
