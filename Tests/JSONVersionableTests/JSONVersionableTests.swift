import XCTest
@testable import JSONVersionable

final class JSONVersionableTests: XCTestCase {
    func testV1Load() {
        let origin = PersonFixtures.simpleV1
        let peopleJSON = origin.json["people"] as! [JSON]
        let firstPerson = peopleJSON.first!
        
        XCTAssertEqual(origin.json["schema_version"] as! Int, 1)
        XCTAssertEqual(peopleJSON.count, 2)
        XCTAssertEqual(firstPerson["name"] as! String, "Fred Weasley")
    }
    
    func testV1ToV2Migration() {
        let origin = PersonFixtures.simpleV1
        let v2Migration = PersonV2Migration().eraseToAnyMigration()
        let v3Migration = PersonV3Migration().eraseToAnyMigration()
        let migration = JSONMigration(currentVersion: 2, versionMigrations: [v2Migration, v3Migration])
        let migratedJSON = try! migration.migration(origin: origin).json
        
        let peopleJSON = migratedJSON["people"] as! [JSON]
        let firstPerson = peopleJSON.first!
        
        XCTAssertEqual(migratedJSON["schema_version"] as! Int, 2)
        XCTAssertEqual(peopleJSON.count, 2)
        XCTAssertEqual(firstPerson["first_name"] as! String, "Fred")
        XCTAssertEqual(firstPerson["last_name"] as! String, "Weasley")
    }
    
    func testV2ToV3Migration() {
        let origin = PersonFixtures.simpleV2
        let v3 = PersonV3Migration().eraseToAnyMigration()
        let migration = JSONMigration(currentVersion: 3, versionMigrations: [v3])
        let migratedJSON = try! migration.migration(origin: origin).json
        
        let peopleJSON = migratedJSON["people"] as! [JSON]
        let firstPerson = peopleJSON.first!
        
        XCTAssertEqual(migratedJSON["schema_version"] as! Int, 3)
        XCTAssertEqual(peopleJSON.count, 2)
        XCTAssertEqual(firstPerson["first_name"] as! String, "Fred")
        XCTAssertEqual(firstPerson["last_name"] as! String, "Weasley")
        XCTAssertEqual(firstPerson["mark_as_favorite"] as! Bool, false)
    }
    
    // TODO: V1 to V3

    static var allTests = [
        ("testV1Load", testV1Load),
        ("testV2ToV3Migration", testV2ToV3Migration)
    ]
}
