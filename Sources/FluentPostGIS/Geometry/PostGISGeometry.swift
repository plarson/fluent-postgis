import WKCodable

public protocol PostGISGeometry {
    var wkbGeometry: WKBGeometry { get }
    func isEqual(to other: PostGISGeometry) -> Bool
}

extension PostGISGeometry where Self: Equatable {
    public func isEqual(to other: PostGISGeometry) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}
