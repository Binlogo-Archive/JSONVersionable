//
//  File.swift
//  
//
//  Created by 王兴彬 on 2021/4/10.
//

import Foundation

struct PersonFixtures {
    
    static var simpleV1: PersonJSONVersionable {
        return PersonJSONVersionable(json: simple(version: 1))
    }
    
    static var simpleV2: PersonJSONVersionable {
        return PersonJSONVersionable(json: simple(version: 2))
    }
    
    static var simpleV3: PersonJSONVersionable {
        return PersonJSONVersionable(json: simple(version: 3))
    }
    
    private static func simple(version: Int) -> [String: Any] {
        let testBundle = Bundle.module
        let filename = "simple-v\(version)"
        let url = testBundle.url(forResource: filename, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        return json
    }
    
}
