import FluentPostgreSQL
import WKCodable

extension QuerySupporting where QueryFilterValue: SQLExpression {
    public static func queryFilterValueGeometry(_ point: PostGISGeometry) -> QueryFilterValue {
        let geometryText = WKTEncoder().encode(point.wkbGeometry)
        return .function("ST_GeomFromEWKT", [.expression(.literal(.string(geometryText)))])
    }
}
