import FluentPostgreSQL
import WKCodable

extension QueryBuilder where
    Database: QuerySupporting,
    Database.QueryFilter: SQLExpression,
    Database.QueryField == Database.QueryFilter.ColumnIdentifier,
    Database.QueryFilterMethod == Database.QueryFilter.BinaryOperator,
    Database.QueryFilterValue == Database.QueryFilter
{
    @discardableResult
    public func filter<T>(_ key: KeyPath<Result, T>, _ filter: PostGISPoint, _ method: Database.QueryFilterMethod, _ value: Double) -> Self
        where T: Encodable
    {
        return filterDistance(Database.queryField(.keyPath(key)), Database.queryFilterValuePostGISPoint(filter), method, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    public func filterDistance<A, T>(_ key: KeyPath<A, T>, _ filter: PostGISPoint, _ method: Database.QueryFilterMethod, _ value: Double) -> Self
    {
        return filterDistance(Database.queryField(.keyPath(key)), Database.queryFilterValuePostGISPoint(filter), method, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    public func filter<T>(_ key: KeyPath<Result, T>, _ filter: Database.QueryFilterValue, _ method: Database.QueryFilterMethod, _ value: Double) -> Self
        where T: Encodable
    {
        return filterDistance(Database.queryField(.keyPath(key)), filter, method, Database.queryFilterValue([value]))
    }

    @discardableResult
    public func filterDistance<A, T>(_ key: KeyPath<A, T>, _ filter: Database.QueryFilterValue, _ method: Database.QueryFilterMethod, _ value: Double) -> Self
    {
        return filterDistance(Database.queryField(.keyPath(key)), filter, method, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    public func filterDistance(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ method: Database.QueryFilterMethod, _ value: Double) -> Self
    {
        return filterDistance(field, filter, method, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    private func filterDistance(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ method: Database.QueryFilterMethod, _ value: Database.QueryFilterValue) -> Self {
        return self.filter(custom: Database.queryFilterDistance(field, filter, method, value))
    }

}

extension QuerySupporting where
    QueryFilter: SQLExpression,
    QueryField == QueryFilter.ColumnIdentifier,
    QueryFilterMethod == QueryFilter.BinaryOperator,
    QueryFilterValue == QueryFilter
{
    public static func queryFilterDistance(_ field: QueryField, _ filter: QueryFilterValue, _ method: QueryFilterMethod, _ value: QueryFilterValue) -> QueryFilter {
        let args: [QueryFilter.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(filter as! PostgreSQLExpression),
        ] as! [QueryFilter.Function.Argument]
        return .binary(.function("ST_Distance", args),
                       method,
                       value)
    }
}

extension QuerySupporting where QueryFilterValue: SQLExpression {
    public static func queryFilterValuePostGISPoint(_ point: PostGISPoint) -> QueryFilterValue {
        let encoder = WKTEncoder()
        let geometryText = encoder.encode(point.wkbPoint)
        return .function("ST_GeomFromEWKT", [.expression(.literal(.string(geometryText)))])
    }
}
