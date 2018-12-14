import FluentPostgreSQL
import WKCodable

extension QuerySupporting where QueryFilterValue: SQLExpression {
    public static func queryFilterValueGeometry(_ point: GISGeometry) -> QueryFilterValue {
        let geometryText = WKTEncoder().encode(point.wkbGeometry)
        return .function("ST_GeomFromEWKT", [.expression(.literal(.string(geometryText)))])
    }
}
