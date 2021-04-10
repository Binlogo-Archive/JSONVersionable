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

public struct JSONMigration<Migration: JSONVersionMigrationProtocol> {
    
    let currentVersion: Migration.JSONType.VersionType
    let versionMigrations: [Migration]
    
    func migration(origin: Migration.JSONType) throws -> Migration.JSONType {
        var final = origin
        var versionMigrationsIterator = versionMigrations.makeIterator()

        while try final.schemaVersion(of: final.json) < currentVersion,
              let versionMigration = versionMigrationsIterator.next() {
            final = try versionMigration.migrate(origin: origin)
        }

        return final
    }
}
