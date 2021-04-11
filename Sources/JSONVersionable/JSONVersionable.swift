import Foundation

public enum MigrationError: Error {
    case missingSchemaVersion
    case unexpectedFormat
    case missingKey(String)
}

public typealias JSON = [String: Any]

public protocol JSONVersionable {
    associatedtype VersionType: Comparable
    var json: JSON { get }
    var schemaVersionKey: String { get }
    func schemaVersion(of json: JSON) throws -> VersionType
}

public extension JSONVersionable {
    func schemaVersion(of json: JSON) throws -> VersionType {
        guard let version = json[schemaVersionKey] as? VersionType else {
            throw MigrationError.missingSchemaVersion
        }
        return version
    }
}

public protocol JSONVersionMigration {
    associatedtype JSONType: JSONVersionable
    func migrate(origin: JSONType) throws -> JSONType
}

public extension JSONVersionMigration {
    func eraseToAnyMigration() -> AnyJSONVersionMigration<JSONType> {
        AnyJSONVersionMigration(self)
    }
}

public struct AnyJSONVersionMigration<JSONType: JSONVersionable>: JSONVersionMigration {
    let migrate: (JSONType) throws -> JSONType
    
    public init<Migration>(_ inner: Migration)
    where
        Migration: JSONVersionMigration,
        Migration.JSONType == JSONType
    {
        migrate = inner.migrate
    }
    
    public func migrate(origin: JSONType) throws -> JSONType {
        try migrate(origin)
    }
}

public struct JSONMigrationProcessor<JSONType: JSONVersionable> {
    
    public typealias Migration = AnyJSONVersionMigration<JSONType>
    
    public let currentVersion: JSONType.VersionType
    public let versionMigrations: [Migration]
    
    public init(currentVersion: JSONType.VersionType, versionMigrations: [Migration]) {
        self.currentVersion = currentVersion
        self.versionMigrations = versionMigrations
    }

    public func migration(origin: JSONType) throws -> JSONType {
        try versionMigrations.reduce(origin) { (current, versionMigration) in
            if try current.schemaVersion(of: current.json) < currentVersion {
                return try versionMigration.migrate(origin: current)
            } else {
                return current
            }
        }
    }
}
