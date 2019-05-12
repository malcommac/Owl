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

import UIKit

/// Represent a single section of the collection.
open class CollectionSection: Equatable, Copying, DifferentiableSection {

    /// Parent director. Section cannot be used in more of than one director.
    internal weak var director: CollectionDirector?
    
    /// Return the index of the section into the parent director.
    public var index: Int? {
        guard let director = director else { return nil }
        return director.sections.firstIndex(of: self)
    }
    
	// MARK: - Public Properties -

	/// Identifier of the section
	public let identifier: String

	/// Items inside the collection
	public private(set) var elements: [ElementRepresentable]

	/// View of the header. It overrides any set value for `headerTitle`.
	public var headerView: CollectionHeaderFooterAdapterProtocol?
	
	public var headerSize: CGSize?

	/// View of the footer. It overrides any set value for `footerView`.
	public var footerView: CollectionHeaderFooterAdapterProtocol?

	public var footerSize: CGSize?

	// MARK: - Differentiable/Equatable Conformances -

	public static func == (lhs: CollectionSection, rhs: CollectionSection) -> Bool {
		guard lhs.identifier == rhs.identifier, lhs.elements.count == rhs.elements.count else {
			return false
		}
		for item in lhs.elements.enumerated() {
			if item.element.isContentEqual(to: rhs.elements[item.offset]) == false {
				return false
			}
		}
		return true
	}

	public var differenceIdentifier: String {
		return self.identifier
	}

	public func isContentEqual(to other: Differentiable) -> Bool {
		guard let other = other as? CollectionSection else {
			return false
		}
		return self.identifier == other.identifier
	}

	// MARK: - FlowLayout Properties -

	/// Implement this method when you want to provide margins for sections in the flow layout.
	/// If you do not implement this method, the margins are obtained from the properties of the flow layout object.
	/// NOTE: It's valid only for flow layout.
	open var sectionInsets: UIEdgeInsets?

	/// The minimum spacing (in points) to use between items in the same row or column.
	/// If you do not implement this method, value is obtained from the properties of the flow layout object.
	/// NOTE: It's valid only for flow layout.
	open var minimumInterItemSpacing: CGFloat?

	/// The minimum spacing (in points) to use between rows or columns.
	/// If you do not implement this method, value is obtained from the properties of the flow layout object.
	/// NOTE: It's valid only for flow layout.
	open var minimumLineSpacing: CGFloat?

	// MARK: - Initialization -

	public required init(original: CollectionSection) {
		self.elements = original.elements
		self.identifier = original.identifier

		self.headerView = original.headerView
		self.footerView = original.footerView
	}

	public required init<C>(source: CollectionSection, elements: C) where C : Collection, C.Element == ElementRepresentable {
		self.elements = Array(elements)
		self.identifier = source.identifier
		
		self.headerView = source.headerView
		self.footerView = source.footerView
	}

	public init(id: String? = nil, elements: [ElementRepresentable] = []) {
		self.elements = elements
		self.identifier = id ?? UUID().uuidString
	}

	public convenience init(id: String? = nil, elements: [ElementRepresentable] = [],
							header: CollectionHeaderFooterAdapterProtocol?, footer: CollectionHeaderFooterAdapterProtocol?) {
		self.init(id: id, elements: elements)
		self.headerView = header
		self.footerView = footer
	}

	
	// MARK: - Content Managegment -
	
	public func set(elements newElements: [ElementRepresentable]) {
        let removedElements = elements
		elements = newElements
        
        for item in removedElements.enumerated() {
            director?.storeInReloadSessionCache(item.element, at: IndexPath(optionalSection: self.index, row: item.offset))
        }
	}
	
	/// Replace a model instance at specified index.
	///
	/// - Parameters:
	///   - model: new instance to use.
	///   - index: index of the instance to replace.
	/// - Returns: old instance, `nil` if provided `index` is invalid.
	@discardableResult
	public func set(element: ElementRepresentable, at index: Int) -> ElementRepresentable? {
		guard index >= 0, index < elements.count else { return nil }
		let oldElement = elements[index]
		elements[index] = element
		return oldElement
	}
	
	/// Add item at given index.
	///
	/// - Parameters:
	///   - model: model to append
	///   - index: destination index; if invalid or `nil` model is append at the end of the list.
	public func add(element: ElementRepresentable?, at index: Int?) {
		guard let element = element else { return }
		guard let index = index, index < elements.count else {
			elements.append(element)
			return
		}
		elements.insert(element, at: index)
	}
	
	/// Add models starting at given index of the array.
	///
	/// - Parameters:
	///   - models: models to insert.
	///   - index: destination starting index; if invalid or `nil` models are append at the end of the list.
	public func add(elements newElements: [ElementRepresentable]?, at index: Int?) {
		guard let newElements = newElements else { return }
		guard let index = index, index < elements.count else {
			elements.append(contentsOf: newElements)
			return
		}
		elements.insert(contentsOf: newElements, at: index)
	}
	
	/// Remove model at given index.
	///
	/// - Parameter index: index to remove.
	/// - Returns: removed model, `nil` if index is invalid.
	@discardableResult
	public func remove(at rowIndex: Int) -> ElementRepresentable? {
		guard rowIndex < elements.count else { return nil }
		let removedElement = elements.remove(at: rowIndex)
        director?.storeInReloadSessionCache(removedElement, at: IndexPath(optionalSection: self.index, row: rowIndex))
        return removedElement
	}
	
	/// Remove model at given indexes set.
	///
	/// - Parameter indexes: indexes to remove.
	/// - Returns: an array of removed indexes starting from the lower index to the last one. Invalid indexes are ignored.
	@discardableResult
	public func remove(atIndexes indexes: IndexSet) -> [ElementRepresentable] {
		var removed: [ElementRepresentable] = []
		indexes.reversed().forEach {
			if $0 < elements.count {
                let removedElement = elements.remove(at: $0)
                director?.storeInReloadSessionCache(removedElement, at: IndexPath(optionalSection: self.index, row: $0))
                removed.append(removedElement)
			}
		}
		return removed
	}
	
	/// Remove all models into the section.
	///
	/// - Parameter kp: `true` to keep the capacity and optimize operations.
	/// - Returns: count removed items.
	@discardableResult
	public func removeAll(keepingCapacity kp: Bool = false) -> Int {
		let count = elements.count
        let removedElements = elements
		elements.removeAll(keepingCapacity: kp)
        
        for item in removedElements.enumerated() {
            director?.storeInReloadSessionCache(item.element, at: IndexPath(optionalSection: self.index, row: item.offset))
        }
        
		return count
	}
	
	/// Swap model at given index to another destination index.
	///
	/// - Parameters:
	///   - sourceIndex: source index
	///   - destIndex: destination index
	public func move(swappingAt sourceIndex: Int, with destIndex: Int) {
		guard sourceIndex < elements.count, destIndex < elements.count else { return }
		swap(&elements[sourceIndex], &elements[destIndex])
	}
	
	/// Remove model at given index and insert at destination index.
	///
	/// - Parameters:
	///   - sourceIndex: source index
	///   - destIndex: destination index
	public func move(from sourceIndex: Int, to destIndex: Int) {
		guard sourceIndex < elements.count, destIndex < elements.count else { return }
		let removed = elements.remove(at: sourceIndex)
		elements.insert(removed, at: destIndex)
	}
	
	// MARK: - Private Functions -
	
	/// Return the best height of the header/footer based upon what kind of item is set.
	/// If a view is set the `UITableView.automaticDimension` is used.
	/// If title is set 0 is returned if string is empty otherwise `CGFloat.leastNonzeroMagnitude`.
	fileprivate func unspecifiedHeightForHeaderFooter(view: TableHeaderFooterAdapterProtocol?, title: String?) -> CGFloat {
		if let _ = view {
			return UITableView.automaticDimension
		}
		if title?.isEmpty ?? true {
			return 0
		}
		return CGFloat.leastNonzeroMagnitude
	}
	
	
}

