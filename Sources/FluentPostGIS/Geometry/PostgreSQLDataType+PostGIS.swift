import PostgreSQL

extension PostgreSQLDataType {
    
    public static var geometricPoint: PostgreSQLDataType {
        return .custom("geometry(Point, \(FluentPostGISSrid))")
    }

    public static var geographicPoint: PostgreSQLDataType {
        return .custom("geography(Point, \(FluentPostGISSrid))")
    }
    
    public static var geometricLineString: PostgreSQLDataType {
        return .custom("geometry(LineString, \(FluentPostGISSrid))")
    }
    
    public static var geographicLineString: PostgreSQLDataType {
        return .custom("geography(LineString, \(FluentPostGISSrid))")
    }
    
    public static var geometricPolygon: PostgreSQLDataType {
        return .custom("geometry(Polygon, \(FluentPostGISSrid))")
    }
    
    public static var geographicPolygon: PostgreSQLDataType {
        return .custom("geography(Polygon, \(FluentPostGISSrid))")
    }
    
    public static var geometricMultiPoint: PostgreSQLDataType {
        return .custom("geometry(MultiPoint, \(FluentPostGISSrid))")
    }
    
    public static var geographicMultiPoint: PostgreSQLDataType {
        return .custom("geography(MultiPoint, \(FluentPostGISSrid))")
    }
    
    public static var geometricMultiLineString: PostgreSQLDataType {
        return .custom("geometry(MultiLineString, \(FluentPostGISSrid))")
    }
    
    public static var geographicMultiLineString: PostgreSQLDataType {
        return .custom("geography(MultiLineString, \(FluentPostGISSrid))")
    }
    
    public static var geometricMultiPolygon: PostgreSQLDataType {
        return .custom("geometry(MultiPolygon, \(FluentPostGISSrid))")
    }
    
    public static var geographicMultiPolygon: PostgreSQLDataType {
        return .custom("geography(MultiPolygon, \(FluentPostGISSrid))")
    }
    
    public static var geometricGeometryCollection: PostgreSQLDataType {
        return .custom("geometry(GeometryCollection, \(FluentPostGISSrid))")
    }
    
    public static var geographicGeometryCollection: PostgreSQLDataType {
        return .custom("geography(GeometryCollection, \(FluentPostGISSrid))")
    }
}
