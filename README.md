# FluentPostGIS

[![Build Status](https://travis-ci.org/plarson/fluent-postgis.svg?branch=master)](https://travis-ci.org/plarson/fluent-postgis)
![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20OS%20X-blue.svg)
![Package Managers](https://img.shields.io/badge/package%20managers-SwiftPM-yellow.svg)
[![Twitter dizm](https://img.shields.io/badge/twitter-dizm-green.svg)](http://twitter.com/dizm)

PostGIS support for [FluentPostgreSQL](https://github.com/vapor/fluent-postgresql) and [Vapor][https://github.com/vapor/vapor)

# Installation

## Swift Package Manager

```swift
.package(url: "https://github.com/plarson/fluent-postgis.git", .branch("master"))
```
# Setup
Import module
```swift
import FluentPostGIS
```

Add to ```configure.swift```
```swift
try services.register(FluentPostGISProvider())
```
# Models
Add ```GISGeographicPoint2D``` to your models
```swift
final class User: PostgreSQLModel {
    var id: Int?
    var name: String
    var location: GISGeographicPoint2D?
}
```
| Geometric Types | Geographic Types  |
|---|---|
|GISGeometricPoint2D|GISGeographicPoint2D|
|GISGeometricLineString2D|GISGeographicLineString2D|
|GISGeometricPolygon2D|GISGeographicPolygon2D|
|GISGeometricMultiPoint2D|GISGeographicMultiPoint2D|
|GISGeometricMultiLineString2D|GISGeographicMultiLineString2D|
|GISGeometricMultiPolygon2D|GISGeographicMultiPolygon2D|
|GISGeometricGeometryCollection2D|GISGeographicGeometryCollection2D|

# Queries
Query locations using ```ST_DWithin```
```swift        
let searchLocation = GISGeographicPoint2D(longitude: -71.060316, latitude: 48.432044)
try User.query(on: conn).filterGeometryDistanceWithin(\User.location, searchLocation, 1000).all().wait()
```

| Queries |
|---|
|filterGeometryContains|
|filterGeometryCrosses|
|filterGeometryDisjoint|
|filterGeometryDistance|
|filterGeometryDistanceWithin|
|filterGeometryEquals|
|filterGeometryIntersects|
|filterGeometryOverlaps|
|filterGeometryTouches|
|filterGeometryWithin|

:gift_heart: Contributing
------------
Please create an issue with a description of your problem or open a pull request with a fix.

:v: License
-------
MIT

:alien: Author
------
Phil Larson - http://dizm.com
