import WKCodable

public protocol GISGeometry {
    var wkbGeometry: WKBGeometry { get }
    func isEqual(to other: GISGeometry) -> Bool
}

extension GISGeometry where Self: Equatable {
    public func isEqual(to other: GISGeometry) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}
