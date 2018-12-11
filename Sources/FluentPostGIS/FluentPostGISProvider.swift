import FluentPostgreSQL

// Adds Fluent PostGIS to your project.
public final class FluentPostGISProvider: Provider {
    public init() {}
    
    public func register(_ services: inout Services) throws {
    }
    
    public func willBoot(_ worker: Container) throws -> Future<Void> {
        return worker.withPooledConnection(to: .psql) { conn in
            return FluentPostGISProvider._setup(on: conn)
        }
    }
    
    public static func _setup(on conn: PostgreSQLConnection) -> Future<Void> {
        struct PGType: Codable {
            var oid: Int32
        }
        return EnablePostGISMigration.prepare(on: conn).then {
            return conn.raw("select oid from pg_type where typname = 'geometry'").all(decoding: PGType.self).map { rows in
                guard let oid = rows.first?.oid else {
                    fatalError("PostGIS not enabled")
                }
                PostgreSQLDataFormat.geometry = PostgreSQLDataFormat(oid)
            }
        }
    }
    
    public func didBoot(_ worker: Container) throws -> Future<Void> {
        return .done(on: worker)
    }
}

public var FluentPostGISSrid: UInt = 4326
