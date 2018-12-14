import FluentPostgreSQL

extension QueryBuilder where
    Database: QuerySupporting,
    Database.QueryFilter: SQLExpression,
    Database.QueryField == Database.QueryFilter.ColumnIdentifier,
    Database.QueryFilterMethod == Database.QueryFilter.BinaryOperator,
    Database.QueryFilterValue == Database.QueryFilter
{
    /// Applies an ST_Contains filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryContains(\.area, point)
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - value: Geometry value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filterGeometryContains<T>(_ key: KeyPath<Result, T>, _ value: GISGeometry) -> Self
        where T: GISGeometry
    {
        return filterGeometryContains(Database.queryField(.keyPath(key)), Database.queryFilterValueGeometry(value))
    }

    /// Applies an ST_Contains filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryContains("area", point)
    ///         .all()
    ///
    /// - parameters:
    ///     - field: Name to a field on the model to filter.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    private func filterGeometryContains(_ field: Database.QueryField, _ value: Database.QueryFilterValue) -> Self {
        return self.filter(custom: Database.queryGeometryContains(field, value))
    }
    
}

extension QuerySupporting where
    QueryFilter: SQLExpression,
    QueryField == QueryFilter.ColumnIdentifier,
    QueryFilterMethod == QueryFilter.BinaryOperator,
    QueryFilterValue == QueryFilter
{
    /// Creates an instance of `QueryFilter` for ST_Contains from a field and value.
    ///
    /// - parameters:
    ///     - field: Field to filter.
    ///     - method: Method to compare field and value.
    ///     - value: Value type.
    public static func queryGeometryContains(_ field: QueryField, _ value: QueryFilterValue) -> QueryFilter {
        let args: [QueryFilter.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(value as! PostgreSQLExpression),
            ] as! [QueryFilter.Function.Argument]
        return .function("ST_Contains", args)
    }
}
