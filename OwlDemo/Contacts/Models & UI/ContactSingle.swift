//
//  ContactSingle.swift
//  Example
//
//  Created by dan on 03/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class ContactSingle: Differentiable, ElementRepresentable, Equatable, Codable {
    var name: String
    var email: String
    var position: String
    var photo: URL
    
    public var differenceIdentifier: String {
        return "\(name)\(email)"
    }
    
    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? ContactSingle else { return false }
        return other == self
    }
    
    public static func == (lhs: ContactSingle, rhs: ContactSingle) -> Bool {
        return lhs.name == rhs.name &&
            lhs.email == rhs.email &&
            lhs.position == rhs.position &&
            lhs.photo == rhs.photo
    }
    
    public static func readFromFile(_ filename: String = "people_db") throws -> [ContactSingle] {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: filename, ofType: "json")!))
        let peoples = try! JSONDecoder().decode([ContactSingle].self, from: data)
        return peoples
    }
    
}
