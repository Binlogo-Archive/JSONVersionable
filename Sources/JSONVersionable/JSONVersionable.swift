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

extension JSONVersionable {
    func schemaVersion(of json: JSON) throws -> VersionType {
        guard let version = json[schemaVersionKey] as? VersionType else {
            throw MigrationError.missingSchemaVersion
        }
        return version
    }
}

public protocol JSONVersionMigrationProtocol {
    associatedtype JSONType: JSONVersionable
    func migrate(origin: JSONType) throws -> JSONType
}

public extension JSONVersionMigrationProtocol {
    
    func eraseToAnyMigration() -> AnyJSONVersionMigration<JSONType> {
        AnyJSONVersionMigration(self)
    }
}

public struct AnyJSONVersionMigration<JSONType: JSONVersionable>: JSONVersionMigrationProtocol {
    
    public init<MigrationProtocol>(_ inner: MigrationProtocol)
    where
        MigrationProtocol: JSONVersionMigrationProtocol,
        MigrationProtocol.JSONType == JSONType
    {
        migrate = inner.migrate
    }
    
    public func migrate(origin: JSONType) throws -> JSONType {
        try migrate(origin)
    }

    let migrate: (JSONType) throws -> JSONType
}

public struct JSONMigration<JSONType: JSONVersionable> {
    
    public typealias Migration = AnyJSONVersionMigration<JSONType>
    
    public init(currentVersion: JSONType.VersionType, versionMigrations: [Migration]) {
        self.currentVersion = currentVersion
        self.versionMigrations = versionMigrations
    }

    public func migration(origin: JSONType) throws -> JSONType {
        var final = origin
        var versionMigrationsIterator = versionMigrations.makeIterator()

        while try final.schemaVersion(of: final.json) < currentVersion,
              let versionMigration = versionMigrationsIterator.next() {
            final = try versionMigration.migrate(origin: origin)
        }

        return final
    }
    
    let currentVersion: JSONType.VersionType
    let versionMigrations: [Migration]
}
