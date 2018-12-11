import PostgreSQL

extension PostgreSQLDataType {
    
    public static var geometricPoint: PostgreSQLDataType {
        return .custom("geometry(Point, \(FluentPostGISSrid))")
    }

    public static var geographicPoint: PostgreSQLDataType {
        return .custom("geography(Point, \(FluentPostGISSrid))")
    }
        
}
