import WKCodable
import PostgreSQL

public protocol GeometryConvertible {
    associatedtype GeometryType: Geometry
    init(geometry: GeometryType)
    var geometry: GeometryType { get }
    func isEqual(to other: Any?) -> Bool
}

extension GeometryConvertible where Self: Equatable {
    public func isEqual(to other: Any?) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

extension GeometryConvertible where Self: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(geometry)
    }
}

extension GeometryConvertible where Self: Codable {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> Self {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let geometry: GeometryType = try decoder.decode(from: value)
            return self.init(geometry: geometry)
        } else {
            throw PostGISError.decode(self, from: data)
        }
    }
    
    public func convertToPostgreSQLData() throws -> PostgreSQLData {
        let encoder = WKBEncoder(byteOrder: .littleEndian)
        let data = encoder.encode(geometry)
        return PostgreSQLData(.geometry, binary: data)
    }
}
