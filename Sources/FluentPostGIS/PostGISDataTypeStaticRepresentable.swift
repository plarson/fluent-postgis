//
//  PostGISDataTypeStaticRepresentable.swift
//  App
//
//  Created by Phil Larson on 11/30/18.
//

import PostgreSQL

extension PostGISPoint: PostgreSQLDataTypeStaticRepresentable, ReflectionDecodable {
        
    /// See `PostgreSQLDataTypeStaticRepresentable`.
    public static var postgreSQLDataType: PostgreSQLDataType { return .spatialPoint }
    
    /// See `ReflectionDecodable`.
    public static func reflectDecoded() throws -> (PostGISPoint, PostGISPoint) {
        return (.init(longitude: 0, latitude: 0), .init(longitude: 1, latitude: 1))
    }
}
