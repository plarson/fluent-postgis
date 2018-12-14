import Async
import Core
import XCTest
import FluentBenchmark
import FluentPostgreSQL
import Fluent
import Foundation
@testable import FluentPostGIS

final class QueryTests: XCTestCase {
    var benchmarker: Benchmarker<PostgreSQLDatabase>!
    var database: PostgreSQLDatabase!
    
    override func setUp() {
        let config: PostgreSQLDatabaseConfig = .init(
            hostname: "localhost",
            port: 5432,
            username: "postgres",
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
    
    func testContains() throws {
        struct UserArea: PostgreSQLModel, Migration {
            var id: Int?
            var area: GISGeometricPolygon2D
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        conn.logger = DatabaseLogger(database: .psql, handler: PrintLogHandler())
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try UserArea.prepare(on: conn).wait()
        defer { try! UserArea.revert(on: conn).wait() }
        
        let point = GISGeometricPoint2D(x: 0, y: 0)
        let point2 = GISGeometricPoint2D(x: 10, y: 0)
        let point3 = GISGeometricPoint2D(x: 10, y: 10)
        let point4 = GISGeometricPoint2D(x: 0, y: 10)
        let lineString = GISGeometricLineString2D(points: [point, point2, point3, point4, point])
        let polygon = GISGeometricPolygon2D(exteriorRing: lineString)
        
        var user = UserArea(id: nil, area: polygon)
        user = try user.save(on: conn).wait()
        
        let testPoint = GISGeometricPoint2D(x: 5, y: 5)
        let all = try UserArea.query(on: conn).filterGeometryContains(\UserArea.area, testPoint).all().wait()
        XCTAssertEqual(all.count, 1)
    }
    
    func testContainsReversed() throws {
        struct UserLocation: PostgreSQLModel, Migration {
            var id: Int?
            var location: GISGeometricPoint2D
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        conn.logger = DatabaseLogger(database: .psql, handler: PrintLogHandler())
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try UserLocation.prepare(on: conn).wait()
        defer { try! UserLocation.revert(on: conn).wait() }
        
        let point = GISGeometricPoint2D(x: 0, y: 0)
        let point2 = GISGeometricPoint2D(x: 10, y: 0)
        let point3 = GISGeometricPoint2D(x: 10, y: 10)
        let point4 = GISGeometricPoint2D(x: 0, y: 10)
        let lineString = GISGeometricLineString2D(points: [point, point2, point3, point4, point])
        let polygon = GISGeometricPolygon2D(exteriorRing: lineString)
        
        let testPoint = GISGeometricPoint2D(x: 5, y: 5)
        var user = UserLocation(id: nil, location: testPoint)
        user = try user.save(on: conn).wait()
        
        let all = try UserLocation.query(on: conn).filterGeometryContains(polygon, \UserLocation.location).all().wait()
        XCTAssertEqual(all.count, 1)
    }
    
    func testContainsWithHole() throws {
        struct UserArea: PostgreSQLModel, Migration {
            var id: Int?
            var area: GISGeometricPolygon2D
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        conn.logger = DatabaseLogger(database: .psql, handler: PrintLogHandler())
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try UserArea.prepare(on: conn).wait()
        defer { try! UserArea.revert(on: conn).wait() }
        
        let point = GISGeometricPoint2D(x: 0, y: 0)
        let point2 = GISGeometricPoint2D(x: 10, y: 0)
        let point3 = GISGeometricPoint2D(x: 10, y: 10)
        let point4 = GISGeometricPoint2D(x: 0, y: 10)
        let lineString = GISGeometricLineString2D(points: [point, point2, point3, point4, point])
        
        let holePoint = GISGeometricPoint2D(x: 2.5, y: 2.5)
        let holePoint2 = GISGeometricPoint2D(x: 7.5, y: 2.5)
        let holePoint3 = GISGeometricPoint2D(x: 7.5, y: 7.5)
        let holePoint4 = GISGeometricPoint2D(x: 2.5, y: 7.5)
        let hole = GISGeometricLineString2D(points: [holePoint, holePoint2, holePoint3, holePoint4, holePoint])
        
        let polygon = GISGeometricPolygon2D(exteriorRing: lineString, interiorRings: [hole])
        
        var user = UserArea(id: nil, area: polygon)
        user = try user.save(on: conn).wait()
        
        let testPoint = GISGeometricPoint2D(x: 5, y: 5)
        let all = try UserArea.query(on: conn).filterGeometryContains(\UserArea.area, testPoint).all().wait()
        XCTAssertEqual(all.count, 0)
        
        let testPoint2 = GISGeometricPoint2D(x: 1, y: 5)
        let all2 = try UserArea.query(on: conn).filterGeometryContains(\UserArea.area, testPoint2).all().wait()
        XCTAssertEqual(all2.count, 1)
    }
    
}
