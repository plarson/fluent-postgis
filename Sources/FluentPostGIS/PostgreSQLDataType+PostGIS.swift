import PostgreSQL

extension PostgreSQLDataType {
    
    public static var spatialPoint: PostgreSQLDataType {
        return .custom("geometry(Point, \(FluentPostGISSrid))")
    }
        
}
