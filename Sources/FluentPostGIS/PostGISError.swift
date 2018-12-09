import Debugging
import PostgreSQL

/// Errors that can be thrown while working with PostgreSQL.
public struct PostGISError: Debuggable {
    /// See `Debuggable`.
    public static let readableName = "PostGIS Error"
    
    /// Error communicating with PostgreSQL wire-protocol
    static func decode<T>(_ type: T.Type, from data: PostgreSQLData) -> PostGISError {
        return .init(identifier: "decode", reason: "Could not decode \(T.self): \(data).")
    }
    
    /// See `Debuggable`.
    public let identifier: String
    
    /// See `Debuggable`.
    public var reason: String
    
    /// See `Debuggable`.
    public var sourceLocation: SourceLocation
    
    /// See `Debuggable`.
    public var stackTrace: [String]
    
    /// See `Debuggable`.
    public var possibleCauses: [String]
    
    /// See `Debuggable`.
    public var suggestedFixes: [String]
    
    /// Create a new `PostGISError`.
    public init(
        identifier: String,
        reason: String,
        possibleCauses: [String] = [],
        suggestedFixes: [String] = [],
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
        ) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = SourceLocation(file: file, function: function, line: line, column: column, range: nil)
        self.stackTrace = PostGISError.makeStackTrace()
        self.possibleCauses = possibleCauses
        self.suggestedFixes = suggestedFixes
    }
}

/// Only includes the supplied closure in non-release builds.
internal func debugOnly(_ body: () -> Void) {
    assert({ body(); return true }())
}

/// Logs a runtime warning.
internal func WARNING(_ string: @autoclosure () -> String) {
    print("[WARNING] [PostGIS] \(string())")
}

/// Logs a runtime error.
internal func ERROR(_ string: @autoclosure () -> String) {
    print("[Error] [PostGIS] \(string())")
}

func VERBOSE(_ string: @autoclosure () -> (String)) {
    #if VERBOSE
    print("[VERBOSE] [PostGIS] \(string())")
    #endif
}
