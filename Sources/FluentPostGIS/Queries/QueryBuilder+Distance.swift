import FluentPostgreSQL

extension QueryBuilder where
    Database: QuerySupporting,
    Database.QueryFilter: SQLExpression,
    Database.QueryField == Database.QueryFilter.ColumnIdentifier,
    Database.QueryFilterMethod == Database.QueryFilter.BinaryOperator,
    Database.QueryFilterValue == Database.QueryFilter
{
    @discardableResult
    public func filterGeometryDistance<T>(_ key: KeyPath<Result, T>, _ filter: GISGeometry, _ method: Database.QueryFilterMethod, _ value: Double) -> Self
        where T: GISGeometry
    {
        return filterGeometryDistance(Database.queryField(.keyPath(key)), Database.queryFilterValueGeometry(filter), method, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    public func filterGeometryDistance<T>(_ key: KeyPath<Result, T>, _ filter: Database.QueryFilterValue, _ method: Database.QueryFilterMethod, _ value: Double) -> Self
        where T: GISGeometry
    {
        return filterGeometryDistance(Database.queryField(.keyPath(key)), filter, method, Database.queryFilterValue([value]))
    }

    @discardableResult
    public func filterGeometryDistance<A, T>(_ key: KeyPath<A, T>, _ filter: Database.QueryFilterValue, _ method: Database.QueryFilterMethod, _ value: Double) -> Self
        where T: GISGeometry
    {
        return filterGeometryDistance(Database.queryField(.keyPath(key)), filter, method, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    public func filterGeometryDistance(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ method: Database.QueryFilterMethod, _ value: Double) -> Self
    {
        return filterGeometryDistance(field, filter, method, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    private func filterGeometryDistance(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ method: Database.QueryFilterMethod, _ value: Database.QueryFilterValue) -> Self {
        return self.filter(custom: Database.queryFilterGeometryDistance(field, filter, method, value))
    }

}

extension QuerySupporting where
    QueryFilter: SQLExpression,
    QueryField == QueryFilter.ColumnIdentifier,
    QueryFilterMethod == QueryFilter.BinaryOperator,
    QueryFilterValue == QueryFilter
{
    public static func queryFilterGeometryDistance(_ field: QueryField, _ filter: QueryFilterValue, _ method: QueryFilterMethod, _ value: QueryFilterValue) -> QueryFilter {
        let args: [QueryFilter.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(filter as! PostgreSQLExpression),
        ] as! [QueryFilter.Function.Argument]
        return .binary(.function("ST_Distance", args), method, value)
    }
}
