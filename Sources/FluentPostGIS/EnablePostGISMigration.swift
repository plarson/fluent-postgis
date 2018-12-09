//
//  EnablePostGISMigration.swift
//  App
//
//  Created by Phil Larson on 11/30/18.
//

import Foundation
import FluentPostgreSQL

public struct EnablePostGISMigration: Migration {
    public typealias Database = PostgreSQLDatabase

    public static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return conn.raw("CREATE EXTENSION IF NOT EXISTS \"postgis\"").run()
    }

    public static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return conn.raw("DROP EXTENSION IF EXISTS \"postgis\"").run()
    }
}
