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
        let hostname = "localhost"
        let config: PostgreSQLDatabaseConfig = .init(
            hostname: hostname,
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
    
    func testPoint() throws {
        struct UserLocation: PostgreSQLModel, Migration {
            var id: Int?
            var location: GISGeometricPoint2D
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        conn.logger = DatabaseLogger(database: .psql, handler: PrintLogHandler())
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try UserLocation.prepare(on: conn).wait()
        defer { try! UserLocation.revert(on: conn).wait() }
        
        let point = GISGeometricPoint2D(x: 1, y: 2)

        var user = UserLocation(id: nil, location: point)
        user = try user.save(on: conn).wait()
        
        let fetched = try UserLocation.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.location, point)
        
        let all = try UserLocation.query(on: conn).filterDistance(\UserLocation.location, user.location, .lessThanOrEqual, 1000).all().wait()
        print(all)
        XCTAssertEqual(all.count, 1)
    }
    
    func testLineString() throws {
        struct UserPath: PostgreSQLModel, Migration {
            var id: Int?
            var path: GISGeometricLineString2D
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        conn.logger = DatabaseLogger(database: .psql, handler: PrintLogHandler())
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try UserPath.prepare(on: conn).wait()
        defer { try! UserPath.revert(on: conn).wait() }
        
        let point = GISGeometricPoint2D(x: 1, y: 2)
        let point2 = GISGeometricPoint2D(x: 2, y: 3)
        let point3 = GISGeometricPoint2D(x: 3, y: 2)
        let lineString = GISGeometricLineString2D(points: [point, point2, point3, point])

        var user = UserPath(id: nil, path: lineString)
        user = try user.save(on: conn).wait()
        
        let fetched = try UserPath.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.path, lineString)
    }
    
    func testPolygon() throws {
        struct UserArea: PostgreSQLModel, Migration {
            var id: Int?
            var area: GISGeometricPolygon2D
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        conn.logger = DatabaseLogger(database: .psql, handler: PrintLogHandler())
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try UserArea.prepare(on: conn).wait()
        defer { try! UserArea.revert(on: conn).wait() }
        
        let point = GISGeometricPoint2D(x: 1, y: 2)
        let point2 = GISGeometricPoint2D(x: 2, y: 3)
        let point3 = GISGeometricPoint2D(x: 3, y: 2)
        let lineString = GISGeometricLineString2D(points: [point, point2, point3, point])
        let polygon = GISGeometricPolygon2D(exteriorRing: lineString, interiorRings: [lineString, lineString])
        
        var user = UserArea(id: nil, area: polygon)
        user = try user.save(on: conn).wait()
        
        let fetched = try UserArea.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.area, polygon)
    }
    
    func testGeometryCollection() throws {
        struct UserCollection: PostgreSQLModel, Migration {
            var id: Int?
            var collection: GISGeometricGeometryCollection2D
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        conn.logger = DatabaseLogger(database: .psql, handler: PrintLogHandler())
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try UserCollection.prepare(on: conn).wait()
        defer { try! UserCollection.revert(on: conn).wait() }
        
        let point = GISGeometricPoint2D(x: 1, y: 2)
        let point2 = GISGeometricPoint2D(x: 2, y: 3)
        let point3 = GISGeometricPoint2D(x: 3, y: 2)
        let lineString = GISGeometricLineString2D(points: [point, point2, point3, point])
        let polygon = GISGeometricPolygon2D(exteriorRing: lineString, interiorRings: [lineString, lineString])
        let geometryCollection = GISGeometricGeometryCollection2D(geometries: [point, point2, point3, lineString, polygon])

        var user = UserCollection(id: nil, collection: geometryCollection)
        user = try user.save(on: conn).wait()
        
        let fetched = try UserCollection.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.collection, geometryCollection)
    }
}
