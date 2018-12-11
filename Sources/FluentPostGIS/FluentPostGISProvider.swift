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
            var typname: String
            var oid: Int32
        }
        return EnablePostGISMigration.prepare(on: conn).then {
            return conn.raw("select oid, typname from pg_type where typname IN ('geometry', 'geography')")
                .all(decoding: PGType.self)
                .map { rows in
                    guard rows.count > 0 else {
                        fatalError("PostGIS is not available")
                    }
                    rows.forEach {
                        switch $0.typname {
                        case "geometry":
                            PostgreSQLDataFormat.geometry = PostgreSQLDataFormat($0.oid)
                        case "geography":
                            PostgreSQLDataFormat.geography = PostgreSQLDataFormat($0.oid)
                        default: break
                        }
                    }
            }
        }
    }
    
    public func didBoot(_ worker: Container) throws -> Future<Void> {
        return .done(on: worker)
    }
}

public var FluentPostGISSrid: UInt = 4326
