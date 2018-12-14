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
    public func filterGeometryContains<T>(_ key: KeyPath<Result, T>, _ filter: GISGeometry) -> Self
        where T: GISGeometry
    {
        return filterGeometryContains(Database.queryField(.keyPath(key)), Database.queryFilterValueGISGeometry(filter))
    }
    
    @discardableResult
    private func filterGeometryContains(_ field: Database.QueryField, _ filter: Database.QueryFilterValue) -> Self {
        return self.filter(custom: Database.queryGeometryContains(field, filter))
    }
    
}

extension QuerySupporting where
    QueryFilter: SQLExpression,
    QueryField == QueryFilter.ColumnIdentifier,
    QueryFilterMethod == QueryFilter.BinaryOperator,
    QueryFilterValue == QueryFilter
{
    public static func queryGeometryContains(_ field: QueryField, _ filter: QueryFilterValue) -> QueryFilter {
        let args: [QueryFilter.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(filter as! PostgreSQLExpression),
            ] as! [QueryFilter.Function.Argument]
        return .function("ST_Contains", args)
    }
}