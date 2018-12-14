import FluentPostgreSQL

extension QueryBuilder where
    Database: QuerySupporting,
    Database.QueryFilter: SQLExpression,
    Database.QueryField == Database.QueryFilter.ColumnIdentifier,
    Database.QueryFilterMethod == Database.QueryFilter.BinaryOperator,
    Database.QueryFilterValue == Database.QueryFilter
{
    @discardableResult
    public func filterGeometryDistanceWithin<T>(_ key: KeyPath<Result, T>, _ filter: PostGISGeometry, _ value: Double) -> Self
        where T: PostGISGeometry
    {
        return filterGeometryDistanceWithin(Database.queryField(.keyPath(key)), Database.queryFilterValueGeometry(filter),  Database.queryFilterValue([value]))
    }
    
    @discardableResult
    public func filterGeometryDistanceWithin<T>(_ key: KeyPath<Result, T>, _ filter: Database.QueryFilterValue, _ value: Double) -> Self
        where T: PostGISGeometry
    {
        return filterGeometryDistanceWithin(Database.queryField(.keyPath(key)), filter, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    public func filterGeometryDistanceWithin<A, T>(_ key: KeyPath<A, T>, _ filter: Database.QueryFilterValue, _ value: Double) -> Self
        where T: PostGISGeometry
    {
        return filterGeometryDistanceWithin(Database.queryField(.keyPath(key)), filter, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    public func filterGeometryDistanceWithin(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ value: Double) -> Self
    {
        return filterGeometryDistanceWithin(field, filter, Database.queryFilterValue([value]))
    }
    
    @discardableResult
    private func filterGeometryDistanceWithin(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ value: Database.QueryFilterValue) -> Self {
        return self.filter(custom: Database.queryFilterGeometryDistanceWithin(field, filter, value))
    }
    
}

extension QuerySupporting where
    QueryFilter: SQLExpression,
    QueryField == QueryFilter.ColumnIdentifier,
    QueryFilterMethod == QueryFilter.BinaryOperator,
    QueryFilterValue == QueryFilter
{
    public static func queryFilterGeometryDistanceWithin(_ field: QueryField, _ filter: QueryFilterValue, _ value: QueryFilterValue) -> QueryFilter {
        let args: [QueryFilter.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(filter as! PostgreSQLExpression),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(value as! PostgreSQLExpression),
            ] as! [QueryFilter.Function.Argument]
        return .function("ST_DWithin", args)
    }
}
