import WKCodable

public protocol GISGeometry {
    var wkbGeometry: WKBGeometry { get }
}
