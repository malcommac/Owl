//
//  ContactCompany.swift
//  Example
//
//  Created by dan on 03/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class ContactCompany: Differentiable, ElementRepresentable, Equatable, Codable {
    var id: String
    var name: String
    var peoples = [ContactSingle]()
    var image: URL
    var email: String = ""
    var shortDescription: String = ""

    public var differenceIdentifier: String {
        return self.id
    }
    
    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? ContactCompany else { return false }
        return other == self
    }
    
    public static func == (lhs: ContactCompany, rhs: ContactCompany) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.peoples == rhs.peoples &&
        lhs.image == rhs.image &&
        lhs.email == rhs.email &&
        lhs.shortDescription == rhs.shortDescription
    }
    
    public init(id: String, name: String, url: URL) {
        self.id = id
        self.name = name
        self.image = url
    }
    
    public static func readFromFile(_ filename: String = "companies_db") throws -> [ContactCompany] {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: filename, ofType: "json")!))
        let companies = try! JSONDecoder().decode([ContactCompany].self, from: data)
        return companies
    }
    
}
