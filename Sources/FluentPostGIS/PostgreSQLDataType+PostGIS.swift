import PostgreSQL

extension PostgreSQLDataType {
    
    public static var geometricPoint: PostgreSQLDataType {
        return .custom("geometry(Point, \(FluentPostGISSrid))")
    }
        
}
