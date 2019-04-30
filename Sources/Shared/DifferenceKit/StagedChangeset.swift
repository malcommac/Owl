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

public struct StagedChangeset<Collection: Swift.Collection> {
	@usableFromInline
	internal var changesets: ContiguousArray<Changeset<Collection>>
	
	@inlinable
	public init<C: Swift.Collection>(_ changesets: C) where C.Element == Changeset<Collection> {
		self.changesets = ContiguousArray(changesets)
	}
	
}

extension StagedChangeset: RandomAccessCollection, RangeReplaceableCollection, MutableCollection {
	public typealias Element = Changeset<Collection>

	@inlinable
	public init() {
		self.init([])
	}
	
	@inlinable
	public var startIndex: Int {
		return changesets.startIndex
	}
	
	@inlinable
	public var endIndex: Int {
		return changesets.endIndex
	}
	
	@inlinable
	public func index(after i: Int) -> Int {
		return changesets.index(after: i)
	}
	
	@inlinable
	public subscript(position: Int) -> Changeset<Collection> {
		get { return changesets[position] }
		set { changesets[position] = newValue }
	}
	
	@inlinable
	public mutating func replaceSubrange<C: Swift.Collection, R: RangeExpression>(_ subrange: R, with newElements: C) where C.Element == Changeset<Collection>, R.Bound == Int {
		changesets.replaceSubrange(subrange, with: newElements)
	}
	
}

extension StagedChangeset: Equatable where Collection: Equatable {
	@inlinable
	public static func == (lhs: StagedChangeset, rhs: StagedChangeset) -> Bool {
		return lhs.changesets == rhs.changesets
	}
}

extension StagedChangeset: ExpressibleByArrayLiteral {
	@inlinable
	public init(arrayLiteral elements: Changeset<Collection>...) {
		self.init(elements)
	}
}


extension StagedChangeset: CustomDebugStringConvertible {
	public var debugDescription: String {
		guard !isEmpty else { return "[]" }
		
		return "[\n\(map { "    \($0.debugDescription.split(separator: "\n").joined(separator: "\n    "))" }.joined(separator: ",\n"))\n]"
	}
}
