//
//  DataSet.swift
//  Example
//
//  Created by dan on 03/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import Foundation

public class DataSet {
    
    public static let shared = DataSet()
    
    public var peoples = [ContactSingle]()
	public var companies = [ContactCompany]()
	public var emoji = [[String]]()

    private init() {
        self.peoples = try! ContactSingle.readFromFile()
        let allCompanies = try! ContactCompany.readFromFile()
        self.companies = allCompanies.map({
            $0.peoples = peoples.choose(Int.random(in: 0..<peoples.count))
            return $0
        })
		
		self.emoji = generateEmojiSections(3, elements: 200)
    }
	
	private func generateEmojiSections(_ sections: Int = 3, elements: Int? = nil) -> [[String]] {
		let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "emoji_db", ofType: "json")!))
		let emoji = try! JSONDecoder().decode([String].self, from: data).shuffled()
		
		var sectionsList = [[String]]()
		let elementsCount = (elements != nil ? elements! : Int.random(in: 3..<emoji.count))
		for idx in 0..<sections {
			let fromIdx = idx * elementsCount
			let toIdx = fromIdx + elementsCount
			let emojInSection = Array(emoji[fromIdx..<toIdx]).shuffled()
			sectionsList.append(emojInSection)
		}
		
		return sectionsList
	}
	
}
