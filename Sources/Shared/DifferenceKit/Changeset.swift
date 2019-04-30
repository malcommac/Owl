//
//  Owl
//  A declarative type-safe framework for building fast and flexible list with Tables & Collections
//
//  Created by Daniele Margutti
//   - Web: https://www.danielemargutti.com
//   - Twitter: https://twitter.com/danielemargutti
//   - Mail: hello@danielemargutti.com
//
//  Copyright © 2019 Daniele Margutti. Licensed under Apache 2.0 License.
//

import Foundation

public struct Changeset<Collection: Swift.Collection> {
	public var data: Collection
	
	public var sectionDeleted: [Int]
	public var sectionInserted: [Int]
	public var sectionUpdated: [Int]
	public var sectionMoved: [(source: Int, target: Int)]
	
	public var elementDeleted: [ElementPath]
	public var elementInserted: [ElementPath]
	public var elementUpdated: [ElementPath]
	public var elementMoved: [(source: ElementPath, target: ElementPath)]

	@inlinable
	public init(
		data: Collection,
		sectionDeleted: [Int] = [],
		sectionInserted: [Int] = [],
		sectionUpdated: [Int] = [],
		sectionMoved: [(source: Int, target: Int)] = [],
		elementDeleted: [ElementPath] = [],
		elementInserted: [ElementPath] = [],
		elementUpdated: [ElementPath] = [],
		elementMoved: [(source: ElementPath, target: ElementPath)] = []
		) {
		self.data = data
		self.sectionDeleted = sectionDeleted
		self.sectionInserted = sectionInserted
		self.sectionUpdated = sectionUpdated
		self.sectionMoved = sectionMoved
		self.elementDeleted = elementDeleted
		self.elementInserted = elementInserted
		self.elementUpdated = elementUpdated
		self.elementMoved = elementMoved
	}
	
	@inlinable
	public var sectionChangeCount: Int {
		return sectionDeleted.count
			+ sectionInserted.count
			+ sectionUpdated.count
			+ sectionMoved.count
	}
	
	@inlinable
	public var elementChangeCount: Int {
		return elementDeleted.count
			+ elementInserted.count
			+ elementUpdated.count
			+ elementMoved.count
	}
	
	@inlinable
	public var changeCount: Int {
		return sectionChangeCount + elementChangeCount
	}
	
	@inlinable
	public var hasSectionChanges: Bool {
		return sectionChangeCount > 0
	}
	
	@inlinable
	public var hasElementChanges: Bool {
		return elementChangeCount > 0
	}

	@inlinable
	public var hasChanges: Bool {
		return changeCount > 0
	}
}

extension Changeset: Equatable where Collection: Equatable {
	public static func == (lhs: Changeset, rhs: Changeset) -> Bool {
		return lhs.data == rhs.data
			&& Set(lhs.sectionDeleted) == Set(rhs.sectionDeleted)
			&& Set(lhs.sectionInserted) == Set(rhs.sectionInserted)
			&& Set(lhs.sectionUpdated) == Set(rhs.sectionUpdated)
			&& Set(lhs.sectionMoved.map(HashablePair.init)) == Set(rhs.sectionMoved.map(HashablePair.init))
			&& Set(lhs.elementDeleted) == Set(rhs.elementDeleted)
			&& Set(lhs.elementInserted) == Set(rhs.elementInserted)
			&& Set(lhs.elementUpdated) == Set(rhs.elementUpdated)
			&& Set(lhs.elementMoved.map(HashablePair.init)) == Set(rhs.elementMoved.map(HashablePair.init))
	}
}

private struct HashablePair<H: Hashable>: Hashable {
	let first: H
	let second: H
}



extension Changeset: CustomDebugStringConvertible {
	public var debugDescription: String {
		guard !data.isEmpty || hasChanges else {
			return """
			Changeset(
			data: []
			)"
			"""
		}
		
		var description = """
		Changeset(
		data: \(data.isEmpty ? "[]" : "[\n        \(data.map { "\($0)" }.joined(separator: ",\n").split(separator: "\n").joined(separator: "\n        "))\n    ]")
		"""
		
		func appendDescription<T>(name: String, elements: [T]) {
			guard !elements.isEmpty else { return }
			
			description += ",\n    \(name): [\n        \(elements.map { "\($0)" }.joined(separator: ",\n").split(separator: "\n").joined(separator: "\n        "))\n    ]"
		}
		
		appendDescription(name: "sectionDeleted", elements: sectionDeleted)
		appendDescription(name: "sectionInserted", elements: sectionInserted)
		appendDescription(name: "sectionUpdated", elements: sectionUpdated)
		appendDescription(name: "sectionMoved", elements: sectionMoved)
		appendDescription(name: "elementDeleted", elements: elementDeleted)
		appendDescription(name: "elementInserted", elements: elementInserted)
		appendDescription(name: "elementUpdated", elements: elementUpdated)
		appendDescription(name: "elementMoved", elements: elementMoved)
		
		description += "\n)"
		return description
	}
}
