# FluentPostGIS

[![Build Status](https://travis-ci.org/plarson/fluent-postgis.svg?branch=master)](https://travis-ci.org/plarson/fluent-postgis)
![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20OS%20X-blue.svg)
![Package Managers](https://img.shields.io/badge/package%20managers-SwiftPM-yellow.svg)
[![Twitter dizm](https://img.shields.io/badge/twitter-dizm-green.svg)](http://twitter.com/dizm)

Experimental (WIP) PostGIS support for [FluentPostgreSQL](https://github.com/vapor/fluent-postgresql)

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
Add ```PostGISPoint``` to your models
```swift
final class User: PostgreSQLModel {
    var id: Int?
    var name: String
    var location: PostGISPoint?
}
```
# Filtering
Query locations using ```ST_Distance```
```swift        
let searchLocation = PostGISPoint(longitude: -71.060316, latitude: 48.432044)
try User.query(on: conn).filterDistance(\User.location, searchLocation, .lessThanOrEqual, 1000).all().wait()
```
:gift_heart: Contributing
------------
Please create an issue with a description of your problem or open a pull request with a fix.

:v: License
-------
MIT

:alien: Author
------
Phil Larson - http://dizm.com
