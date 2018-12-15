import WKCodable
import PostgreSQL

public protocol WKGeometryConvertible {
    associatedtype GeometryType: Geometry
    init(geometry: GeometryType)
    var geometry: GeometryType { get }
    func isEqual(to other: Any?) -> Bool

}

extension WKGeometryConvertible where Self: Equatable {
    public func isEqual(to other: Any?) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

extension WKGeometryConvertible where Self: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(geometry)
    }
}

extension WKGeometryConvertible where Self: Codable {
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

public struct AnyGeometryConvertible {
    public typealias WKType = Geometry
    
    init<T: WKGeometryConvertible>(_ base: T) {
        self.wkbGeometry = base.geometry
    }

    func isEqual(to other: Any?) -> Bool {
        guard let other = other as? AnyGeometryConvertible else { return false }
        return wkbGeometry.isEqual(to: other.wkbGeometry)
    }

    let wkbGeometry: Geometry
}
