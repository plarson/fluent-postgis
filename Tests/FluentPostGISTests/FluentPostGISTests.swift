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
            var location: PostGISPoint?
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        conn.logger = DatabaseLogger(database: .psql, handler: PrintLogHandler())
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try User.prepare(on: conn).wait()
        defer { try! User.revert(on: conn).wait() }
        
        let point = PostGISPoint(longitude: -71.060316, latitude: 48.432044)
        var user = User(id: nil, name: "Tanner", location: point)
        user = try user.save(on: conn).wait()
        
        let fetched = try User.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.location, point)
        
        let all = try User.query(on: conn).filterDistance(\User.location, user.location!, .lessThanOrEqual, 1000).all().wait()
        print(all)
        XCTAssertEqual(all.count, 1)
    }
}
