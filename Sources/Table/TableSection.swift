//
//  TableSection.swift
//  FlowKit2
//
//  Created by dan on 04/03/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class TableSection: Equatable, Copying, DifferentiableSection {

	// MARK: - Public Properties -

	/// Identifier of the section
	public let identifier: String

	/// Title of the header; if `headerView` is set this value is ignored.
	public var headerTitle: String?

	/// Title of the footer; if `footerView` is set this value is ignored.
	public var footerTitle: String?

	/// View of the header. It overrides any set value for `headerTitle`.
	public var headerView: TableHeaderFooterAdapterProtocol?

	/// View of the footer. It overrides any set value for `footerView`.
	public var footerView: TableHeaderFooterAdapterProtocol?

    /// Return the height of the header when no estimated height is specified.
    internal var unspecifiedHeaderHeight: CGFloat {
        return unspecifiedHeightForHeaderFooter(view: headerView, title: headerTitle)
    }
    
    /// Return the height of the footer when no estimated height is specified.
    internal var unspecifiedFooterHeight: CGFloat {
        return unspecifiedHeightForHeaderFooter(view: footerView, title: footerTitle)
    }
    
	/// If `true` the content of the section is collapsed and no rows are visible.
	public var isCollapsed = false

	/// Title of the section. If value is set it will displayed into the table's section indexes.
	/// By default is `nil`.
	public var indexTitle: String?

	/// The content of the section, including collapsed/invisible rows.
	private var allElements: [ElementRepresentable]

	/// Identify the content of the table, single rows.
	public var elements: [ElementRepresentable] {
		get {
			return (isCollapsed ? [] : allElements)
		}
		set {
			allElements = newValue
		}
	}

	// MARK: - DifferentiableSection Conformance -

	public func isContentEqual(to other: Differentiable) -> Bool {
		guard let other = other as? TableSection,
			elements.count == other.elements.count else {
				return false
		}
		for item in elements.enumerated() {
			if item.element.isContentEqual(to: other.elements[item.offset]) == false {
				return false
			}
		}
		return true
	}

	public var differenceIdentifier: String {
		return self.identifier
	}

	public static func == (lhs: TableSection, rhs: TableSection) -> Bool {
		return lhs.identifier == rhs.identifier
	}

	// MARK: - Initialization -

	required init(original: TableSection) {
		self.allElements = original.allElements
		self.identifier = original.identifier
		self.headerTitle = original.headerTitle
		self.footerTitle = original.footerTitle
		self.headerView = original.headerView
		self.footerView = original.footerView
		self.isCollapsed = original.isCollapsed
	}

	public required init<C>(source: TableSection, elements: C) where C : Collection, C.Element == ElementRepresentable {
		self.allElements = Array(elements)
		self.identifier = source.identifier

		self.headerTitle = source.headerTitle
		self.footerTitle = source.footerTitle

		self.headerView = source.headerView
		self.footerView = source.footerView
	}
	
	public init(id: String? = nil, elements: [ElementRepresentable] = []) {
		self.allElements = elements
		self.identifier = id ?? UUID().uuidString
	}
    
    public convenience init(id: String? = nil, elements: [ElementRepresentable] = [],
                            header: TableHeaderFooterAdapterProtocol, footer: TableHeaderFooterAdapterProtocol) {
        self.init(id: id, elements: elements)
        self.headerView = header
        self.footerView = footer
    }

	public convenience init(id: String? = nil, elements: [ElementRepresentable] = [],
							header: String? = nil, footer: String? = nil) {
		self.init(id: id, elements: elements)
		self.headerTitle = header
		self.footerTitle = footer
	}

	// MARK: - Content Managegment -
	
    /// Replace the current content of the elements into the section with a new set.
    ///
    /// - Parameter newElements: new elements.
	public func set(elements newElements: [ElementRepresentable]) {
		allElements = newElements
	}

	/// Replace a model instance at specified index.
	///
	/// - Parameters:
	///   - model: new instance to use.
	///   - index: index of the instance to replace.
	/// - Returns: old instance, `nil` if provided `index` is invalid.
	@discardableResult
	public func set(element: ElementRepresentable, at index: Int) -> ElementRepresentable? {
		guard index >= 0, index < allElements.count else { return nil }
		let oldElement = allElements[index]
		allElements[index] = element
		return oldElement
	}

	/// Add a new element at given index.
	///
	/// - Parameters:
	///   - model: element instance to append. Must be representable.
	///   - index: destination index; if invalid or `nil` model is append at the end of the list.
	public func add(element: ElementRepresentable?, at index: Int?) {
		guard let element = element else { return }
		guard let index = index, index < allElements.count else {
			allElements.append(element)
			return
		}
		allElements.insert(element, at: index)
	}

	/// Add elements starting at given index of the array.
	///
	/// - Parameters:
	///   - models: models to insert.
	///   - index: destination starting index; if invalid or `nil` models are append at the end of the list.
	public func add(elements: [ElementRepresentable]?, at index: Int?) {
		guard let elements = elements else { return }
		guard let index = index, index < allElements.count else {
			allElements.append(contentsOf: elements)
			return
		}
		allElements.insert(contentsOf: elements, at: index)
	}

	/// Remove element at given index.
	///
	/// - Parameter index: index to remove.
	/// - Returns: removed model, `nil` if index is invalid.
	@discardableResult
	public func remove(at index: Int) -> ElementRepresentable? {
		guard index < allElements.count else { return nil }
		return allElements.remove(at: index)
	}

	/// Remove elements at given indexes set.
	///
	/// - Parameter indexes: indexes to remove.
	/// - Returns: an array of removed indexes starting from the lower index to the last one. Invalid indexes are ignored.
	@discardableResult
	public func remove(atIndexes indexes: IndexSet) -> [ElementRepresentable] {
		var removed: [ElementRepresentable] = []
		indexes.reversed().forEach {
			if $0 < allElements.count {
				removed.append(allElements.remove(at: $0))
			}
		}
		return removed
	}

	/// Remove all elements into the section.
	///
	/// - Parameter kp: `true` to keep the capacity and optimize operations.
	/// - Returns: count removed items.
	@discardableResult
	public func removeAll(keepingCapacity kp: Bool = false) -> Int {
		let count = allElements.count
		allElements.removeAll(keepingCapacity: kp)
		return count
	}

	/// Swap element at given index to another destination index.
	///
	/// - Parameters:
	///   - sourceIndex: source index
	///   - destIndex: destination index
	public func move(swappingAt sourceIndex: Int, with destIndex: Int) {
		guard sourceIndex < allElements.count, destIndex < allElements.count else { return }
		swap(&allElements[sourceIndex], &allElements[destIndex])
	}

	/// Remove element at given index and insert at destination index.
	///
	/// - Parameters:
	///   - sourceIndex: source index
	///   - destIndex: destination index
	public func move(from sourceIndex: Int, to destIndex: Int) {
		guard sourceIndex < allElements.count, destIndex < allElements.count else { return }
		let removed = allElements.remove(at: sourceIndex)
		allElements.insert(removed, at: destIndex)
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
