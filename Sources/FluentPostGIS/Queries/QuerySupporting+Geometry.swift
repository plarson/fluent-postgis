import FluentPostgreSQL
import WKCodable

extension QuerySupporting where QueryFilterValue: SQLExpression {
    public static func queryFilterValueGeometry<T: GeometryConvertible>(_ geometry: T) -> QueryFilterValue {
        let geometryText = WKTEncoder().encode(geometry.geometry)
        return .function("ST_GeomFromEWKT", [.expression(.literal(.string(geometryText)))])
    }
}
