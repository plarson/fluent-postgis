import Async
import Core
import XCTest
import FluentBenchmark
import FluentPostgreSQL
import Fluent
import Foundation
@testable import FluentPostGIS

final class FluentPostGISTests: XCTestCase {
    var benchmarker: Benchmarker<PostgreSQLDatabase>!
    var database: PostgreSQLDatabase!
    
    override func setUp() {
        #if os(macOS)
        let hostname = "localhost"
        #else
        let hostname = "psql"
        #endif
        
        let config: PostgreSQLDatabaseConfig = .init(
            hostname: hostname,
            port: 5432,
            username: "plarson",
            database: "postgis_tests"
        )
        database = PostgreSQLDatabase(config: config)
        let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        benchmarker = try! Benchmarker(database, on: eventLoop, onFail: XCTFail)
        let conn = try! benchmarker.pool.requestConnection().wait()
        defer { benchmarker.pool.releaseConnection(conn) }
        try! FluentPostgreSQLProvider._setup(on: conn).wait()
        try! FluentPostGISProvider._setup(on: conn).wait()
    }
    
    func testPoint() throws {
        struct User: PostgreSQLModel, Migration {
            static let entity = "users"
            var id: Int?
            var name: String
            var location: GISGeometricPoint2D?
            var path: GISGeometricLineString2D?
            var polygon: GISGeometricPolygon2D?
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        conn.logger = DatabaseLogger(database: .psql, handler: PrintLogHandler())
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try User.prepare(on: conn).wait()
        defer { try! User.revert(on: conn).wait() }
        
        let point = GISGeometricPoint2D(x: -71.060316, y: 48.432044)
        let point2 = GISGeometricPoint2D(x: -71.060316, y: 49.432044)
        let point3 = GISGeometricPoint2D(x: -72.060316, y: 48.432044)
        let lineString = GISGeometricLineString2D(points: [point, point2, point3, point])
        
        let polygon = GISGeometricPolygon2D(exteriorRing: lineString, interiorRings: [])
        
        var user = User(id: nil, name: "Tanner", location: point, path: lineString, polygon: polygon)
        user = try user.save(on: conn).wait()
        
        let fetched = try User.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.location, point)
        
        let all = try User.query(on: conn).filterDistance(\User.location, user.location!, .lessThanOrEqual, 1000).all().wait()
        print(all)
        XCTAssertEqual(all.count, 1)
    }
}
