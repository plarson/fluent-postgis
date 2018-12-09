//
//  PostgreSQLDataType+PostGIS.swift
//  App
//
//  Created by Phil Larson on 11/30/18.
//

import PostgreSQL

extension PostgreSQLDataType {
    
    public static var spatialPoint: PostgreSQLDataType {
        return .custom("geometry(Point, \(FluentPostGISSrid))")
    }
        
}
