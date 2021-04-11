//
//  PersonMigration.swift
//  
//
//  Created by 王兴彬 on 2021/4/10.
//

import Foundation
@testable import JSONVersionable

struct PersonJSONVersionable: JSONVersionable {
    typealias VersionType = Int
    
    var json: JSON
    
    var schemaVersionKey: String {
        return "schema_version"
    }
}

struct PersonV2Migration: JSONVersionMigration {
    func migrate(origin: PersonJSONVersionable) throws -> PersonJSONVersionable {
        var mutableContent = origin.json
        
        guard var people = mutableContent["people"] as? [[String:Any]] else {
            throw MigrationError.missingKey("people")
        }
        
        for personIndex in people.indices {
            guard let fullName = people[personIndex]["name"] as? String else {
                throw MigrationError.missingKey("name")
            }
            
            // This conversion of `name` into `first_name` and `last_name` is not very complete
            // but a bullet proof solution is outside the scope of this demo.
            if
                let firstName: Substring = fullName.split(separator: " ").first,
                let lastName: Substring = fullName.split(separator: " ").last
            {
                people[personIndex].updateValue(String(firstName), forKey: "first_name")
                people[personIndex].updateValue(String(lastName), forKey: "last_name")
                people[personIndex].removeValue(forKey: "name")
            } else {
                // If we can not split the name into two parts, just put the whole thing in `first_name`.
                people[personIndex].updateValue(fullName, forKey: "first_name")
                people[personIndex].removeValue(forKey: "name")
            }
        }
        mutableContent.updateValue(people, forKey: "people")
        mutableContent.updateValue(2, forKey: "schema_version")
        
        return PersonJSONVersionable(json: mutableContent)
    }
}

struct PersonV3Migration: JSONVersionMigration {
    func migrate(origin: PersonJSONVersionable) throws -> PersonJSONVersionable {
        var mutableContent = origin.json
        
        guard var people = mutableContent["people"] as? [JSON] else {
            throw MigrationError.missingKey("people")
        }
        
        for personIndex in people.indices {
            people[personIndex].updateValue(false, forKey: "mark_as_favorite")
        }
        
        mutableContent.updateValue(people, forKey: "people")
        mutableContent.updateValue(3, forKey: "schema_version")
        
        return PersonJSONVersionable(json: mutableContent)
    }
}
