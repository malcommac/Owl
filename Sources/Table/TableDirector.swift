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

open class TableDirector: NSObject {

	// MARK: - Private Properties -

	/// Registered cell identifiers.
	internal var cellReuseIDs = Set<String>()

	/// Registered header/footer's view identifiers.
	internal var headerFooterReuseIdentifiers = Set<String>()

    /// Registered adapters for table.
    private var cellAdapters = [String: TableCellAdapterProtocol]()
    
    /// Registered adapters for header/footers.
    private var headerFooterAdapters = [String: TableHeaderFooterAdapterProtocol]()
    
    /// Cached items. Used to provide an object feedback on `...didEnd` events of the cells.
    /// Elements are removed after the event is dispatched.
    private var cachedItems = [IndexPath: ElementRepresentable]()
    
    /// Is in reload session operation.
    private var isInReloadSession: Bool = false {
        didSet {
            if isInReloadSession == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                    self.cachedItems.removeAll()
                }
            }
        }
    }
    
    @discardableResult
    internal func storeInReloadSessionCache(_ element: ElementRepresentable, at indexPath: IndexPath?) -> Bool {
        guard isInReloadSession, let indexPath = indexPath else { return false }
        cachedItems[indexPath] = element
        return true
    }
    
	// MARK: - Public Properties -

	/// Managed `UITableView` instance, not retained.
	public private(set) weak var table: UITableView?

	/// Events related to the behaviour of the table.
	public var scrollViewEvents = ScrollViewEventsHandler()
	
	/// Sections of the table.
	public private(set) var sections = [TableSection]()
    
	/// Return first section.
	public var firstSection: TableSection? {
		return sections.first
	}

	/// Return last section.
	public var lastSection: TableSection? {
		return sections.last
	}

	/// Setup the height of the row.
	/// By default the height is s
	public var rowHeight: RowHeight = .`default` {
		didSet {
			switch rowHeight {
			case .explicit(let h):
				table?.rowHeight = h
				table?.estimatedRowHeight = h
			case .auto(let estimate):
				table?.rowHeight = UITableView.automaticDimension
				table?.estimatedRowHeight = estimate
			case .default:
				table?.rowHeight = UITableView.automaticDimension
				table?.estimatedRowHeight = UITableView.automaticDimension
			}
		}
	}

	// MARK: - Initialization -

    /// Initialize a new director for specified table.
    ///
    /// - Parameter table: table to manage.
	public init(table: UITableView) {
		super.init()
		self.table = table
		self.rowHeight = .default
		table.dataSource = self
		table.delegate = self
	}

	// MARK: - Register Cell Adapters -
	
	/// Register a sequence of adapter for the table. If an adapter is already
	/// registered request will be ignored automatically.
	///
	/// - Parameter adapters: adapters to register.
	public func registerCellAdapters(_ adapters: [TableCellAdapterProtocol]) {
		adapters.forEach {
			registerCellAdapter($0)
		}
	}

	/// Register a new adapter for the table.
	/// An adapter represent the entity composed by the pair <model, cell>
	/// used by the directory to manage their representation inside the table itself.
	/// If adapter is already registered it will be ignored automatically.
	///
	/// - Parameter adapter: adapter instance to register.
    @discardableResult
	public func registerCellAdapter(_ adapter: TableCellAdapterProtocol) -> String {
        let id = adapter.modelIdentifier
		guard cellAdapters[id] == nil else {
			return id
		}
		cellAdapters[id] = adapter
		adapter.registerReusableCellViewForDirector(self)
        return id
	}

	/// Return a list of the adapters involved into the render of the the given models
	/// at paths. Functions returns an array of `PrefetchModelsGroup` which contains the
	/// path/instances of the models involved and their respective adapter.
	///
	/// - Parameter paths: paths of the model instances.
	/// - Returns: `[PrefetchModelsGroup]`
	internal func cellAdaptersForIndexPaths(_ paths: [IndexPath]) -> [PrefetchModelsGroup] {
		let result = paths.reduce(into: [String: PrefetchModelsGroup]()) { (result, indexPath) in
			let model = sections[indexPath.section].elements[indexPath.item]

			var context = result[model.modelClassIdentifier]
			if context == nil {
				guard let adapter = cellAdapters[model.modelClassIdentifier] else {
					fatalError("Failed to get adapter for model: '\(model)' at (\(indexPath.section),\(indexPath.row))")
				}
				context = PrefetchModelsGroup(adapter: adapter)
			}
			context?.models.append(model)
			context?.indexPaths.append(indexPath)
		}
		return Array(result.values)
	}
    
    // MARK: - Register Header/Footer Adapters -
    
    /// Register a set of adapters to render header/footer's custom views.
    ///
    /// - Parameter adapters: adapters to register.
    public func registerHeaderFooterAdapters(_ adapters: [TableHeaderFooterAdapterProtocol]) {
        adapters.forEach {
            registerHeaderFooterAdapter($0)
        }
    }
    
    /// Register a new adapter to render custom header/footer's view.
    ///
    /// - Parameter adapter: adapter to register.
    /// - Returns: registered identifier.
    @discardableResult
    public func registerHeaderFooterAdapter(_ adapter: TableHeaderFooterAdapterProtocol) -> String {
        let id = adapter.modelCellIdentifier
        guard headerFooterAdapters[id] == nil else {
            return id
        }
        headerFooterAdapters[id] = adapter
        return adapter.registerHeaderFooterViewForDirector(self)
    }
    
    /// Return associated adapter to render specific header/footer view instance.
    ///
    /// - Parameter view: view to render, fails if it's not a subclass of `UITableViewHeaderFooterView`.
    /// - Returns: adapter.
    @usableFromInline
    internal func adapterForHeaderFooterView(_ view: UIView) -> TableHeaderFooterAdapterProtocol? {
        guard let view = view as? UITableViewHeaderFooterView else { return nil }
        return headerFooterAdapters[type(of: view).reusableViewIdentifier]
    }
	
	// MARK: - Add Sections -

	/// Replace sections of the table with another set.
	///
	/// - Parameter sections: s
	public func set(sections: [TableSection]) {
		self.sections = sections
        sections.forEach { $0.director = self }
	}
	
	/// Append a new section at the specified index of the table.
	/// If `index` is `nil` or not specified section will be happend
	/// at the bottom of the table.
	///
	/// - Parameters:
	///   - section: section to append.
	///   - index: destination index, `nil` to append section at the bottom of the table.
	public func add(section: TableSection, at index: Int? = nil) {
        section.director = self
		guard let index = index, index < sections.count else {
			sections.append(section)
			return
		}
		sections.insert(section, at: index)
	}
	
	/// Add multiple section starting at specified index.
	/// If `index` is `nil` or omitted all sections will be added at the end of tha table.
	///
	/// - Parameters:
	///   - newSections: sections to append.
	///   - index: destination index, `nil` to append sections at the botton of the table.
	public func add(sections newSections: [TableSection], at index: Int? = nil) {
        newSections.forEach { $0.director = self }
		guard let index = index, index < sections.count else {
			sections.append(contentsOf: newSections)
			return
		}
		sections.insert(contentsOf: newSections, at: index)
	}
	
	// MARK: - Get Sections -
	
	/// Get the section at specified index.
	/// If `index` is invalid `nil` is returned.
	///
	/// - Parameter index: index of the section to get.
	/// - Returns: `TableSection`
	public func section(at index: Int) -> TableSection? {
		guard index < sections.count else {
			return nil
		}
		return sections[index]
	}
    
    /// Return section with given unique identifier.
    ///
    /// - Parameter uuid: unique identifier.
    /// - Returns: `TableSection`
    public func section(_ uuid: String) -> TableSection? {
        return sections.first(where: { $0.identifier == uuid })
    }

	/// Return element at given path. If index is invalid `nil` is returned.
	///
	/// - Parameters:
	///   - indexPath: index path to retrive
	///   - safe: `true` to return nil if path is invalid, `false` to perform an unchecked retrive.
	/// - Returns: model
	public func elementAt(_ indexPath: IndexPath) -> ElementRepresentable? {
		guard indexPath.section >= 0, indexPath.row >= 0,
			indexPath.section < self.sections.count,
			indexPath.row < sections[indexPath.section].elements.count else {
				return nil
		}
		return sections[indexPath.section].elements[indexPath.section]
	}
	
	// MARK: - Remove Sections -
	
	/// Remove section at specified index.
	/// If `index` is invalid no action is made and function return `nil`.
	///
	/// - Parameter index: index of the section to remove.
	/// - Returns: Removed `TableSection`
	@discardableResult
	public func remove(section index: Int) -> TableSection? {
		guard index < sections.count else {
			return nil
		}
        sections[index].removeAll() // used to fill temporary cache if needed
        let removedSection = sections.remove(at: index)
        removedSection.director = nil
        return removedSection
	}

	/// Remove sections at specified indexes.
	/// Sections are removed in reverse order to keep consistancy;
	/// any invalid index is ignored.
	///
	/// - Parameter indexes: indexes to remove.
	/// - Returns: removed `TableSection` array.
	@discardableResult
	public func remove(sectionsAt indexes: IndexSet) -> [TableSection] {
		var removed = [TableSection]()
		indexes.reversed().forEach {
			if $0 < sections.count {
                sections[$0].removeAll() // used to fill temporary cache if needed
				removed.append(sections.remove(at: $0))
			}
		}
        removed.forEach { $0.director = nil }
		return removed
	}

	/// Remove all sections from the table.
	///
	/// - Parameter keepingCapacity: Pass `true` to keep the existing capacity
	///of the array after removing its elements. The default value is `false`.
	/// - Returns: removed `TableSections`.
	@discardableResult
	public func removeAll(keepingCapacity: Bool = false) -> [TableSection] {
		let removedSections = sections
        
        for removedSection in removedSections.enumerated() { // used to fill temporary cache if needed
            removedSection.element.removeAll()
            removedSection.element.director = nil
        }
		
        sections.removeAll(keepingCapacity: keepingCapacity)
		return removedSections
	}

	// MARK: - Move Sections -

	/// Swap source section at specified index with another section.
	/// If indexes are not valid no operation is made.
	///
	/// - Parameters:
	///   - sourceIndex: index of the source section.
	///   - destIndex: index of the destination section
	public func move(swappingAt sourceIndex: Int, with destIndex: Int) {
		guard sourceIndex < sections.count, destIndex < sections.count,
			sourceIndex != destIndex else {
			return
		}
		swap(&sections[sourceIndex], &sections[destIndex])
	}

	/// Move section at specified index to a destination index.
	/// If indexes are invalids no operation is made.
	///
	/// - Parameters:
	///   - sourceIndex: index of the source section.
	///   - destIndex: index of the destination section.
	public func move(from sourceIndex: Int, to destIndex: Int) {
		guard sourceIndex < sections.count, destIndex < sections.count,
			sourceIndex != destIndex else {
			return
		}
		let removed = sections.remove(at: sourceIndex)
		sections.insert(removed, at: destIndex)
	}
	
	// MARK: - Add Items -
	
	/// Append items at the bottom of section at specified index.
	/// If section index is not specified a new section is created and append
	/// at the end of the table with all items.
	///
	/// - Parameters:
	///   - items: items to append.
	///   - sectionIdx: index of the destination section, `nil` to create a new last section.
	/// - Returns: target `TableSection`.
	@discardableResult
	public func add(elements: [ElementRepresentable], inSection sectionIdx: Int? = nil) -> TableSection {
		guard let sectionIdx = sectionIdx, sectionIdx < sections.count else {
			let newSection = TableSection(elements: elements)
            self.add(section: newSection)
            return newSection
		}
		
		let destinationSection = sections[sectionIdx]
		destinationSection.elements.append(contentsOf: elements)
		return destinationSection
	}
	
	// MARK: - Reload Contents -
	
	/// Request for table contents reload.
    /// This call must executed in the main thread in order to avoid weird stuff.
	///
	/// - Parameters:
	///   - update: this callback can be used to perform changes in your table's data (both from
	///				section and section's items perspective). At the end of the execution a
	///				fast diff is made automatically to get the differences before/after and perform
	/// 			an optional automatic animation.
	///				You must to return the animation to be performed at the end of the reload.
	///   - completion: completion is called at the end of the reload. In fact there is not an event
	///					which indicates the end of the reload, so the method is called automatically
	///					after a fixed time (0.25s).
	public func reload(afterUpdate update: ((TableDirector) -> UITableView.RowAnimation)? = nil,
					   completion: (() -> Void)? = nil) {
		guard let update = update else {
			table?.reloadData()
			return
		}
		
        isInReloadSession = true
		
        let oldSections = self.sections.map { $0.copy() }
		let rowAnimation = update(self)
		let changeset = StagedChangeset(source: oldSections, target: sections)
		
		table?.reload(using: changeset, with: rowAnimation, interrupt: { (changset) -> Bool in
			return false
		}, setData: { collection in
			sections = collection
		})
        
        isInReloadSession = false
        
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                completion()
            }
        }
	}
	
	// MARK: - Private Functions -

	/// Return the adapter used to represent the item at given path.
	///
	/// - Parameter path: path of the item to render.
	/// - Returns: model instance and adapter used to represent it.
	internal func context(forItemAt path: IndexPath) -> (model: ElementRepresentable, adapter: TableCellAdapterProtocol) {
		let modelInstance = sections[path.section].elements[path.row]
		guard let adapter = self.cellAdapters[modelInstance.modelClassIdentifier] else {
			fatalError("No register adapter for model '\(modelInstance.modelClassIdentifier)' at (\(path.section),\(path.row))")
		}
		return (modelInstance, adapter)
	}
    
    /// Cached context return temporary cached element to provide rationalle values for didEnd events which works with removed elements.
    ///
    /// - Parameters:
    ///   - path: path of the element.
    ///   - removeFromCache: `true` to remove element cache after request. By default is `true`.
    /// - Returns: cached element and adapter if any.
    internal func cachedContext(forItemAt path: IndexPath, removeFromCache: Bool = true) -> (model: ElementRepresentable, adapter: TableCellAdapterProtocol)? {
        guard let modelInstance = cachedItems[path], let adapter = self.cellAdapters[modelInstance.modelClassIdentifier]  else {
            return nil
        }
        if removeFromCache {
            cachedItems.removeValue(forKey: path)
        }
        return (modelInstance, adapter)
    }

	internal func adapterForCell(_ cell: UITableViewCell) -> TableCellAdapterProtocol? {
		return cellAdapters.first(where: { item in
			return item.value.modelCellType == type(of: cell)
		})?.value
	}

}

// MARK: - UITableViewDataSource/UITableViewDelegate -

extension TableDirector: UITableViewDataSource, UITableViewDelegate {

	// MARK: - Required -

	public func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].elements.count
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let (model, adapter) = context(forItemAt: indexPath)
		let cell = adapter.dequeueCell(inTable: tableView, at: indexPath)
		adapter.dispatchEvent(.dequeue, model: model, cell: cell, path: indexPath, params: nil)
		return cell
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.willDisplay, model: model, cell: cell, path: indexPath, params: nil)
	}

	// MARK: - Row Height -

	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch rowHeight {
		case .default:
			let (model, adapter) = context(forItemAt: indexPath)
			guard let height = adapter.dispatchEvent(.rowHeight, model: model, cell: nil, path: indexPath) as? CGFloat else {
				return tableView.rowHeight
			}
			return height

		case .auto(_):
			return UITableView.automaticDimension

		case .explicit(let height):
			return height
		}
	}

	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.rowHeightEstimated, model: model, cell: nil, path: indexPath) as? CGFloat) ?? UITableView.automaticDimension
	}

	// MARK: - Header/Footer -
	
	public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
		let adapter = adapterForHeaderFooterView(view)
        let _ = adapter?.dispatch(.endDisplay, isHeader: true, view: view, section: section)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        let adapter = adapterForHeaderFooterView(view)
        let _ = adapter?.dispatch(.endDisplay, isHeader: false, view: view, section: section)
	}

	public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let adapter = adapterForHeaderFooterView(view)
        let _ = adapter?.dispatch(.willDisplay, isHeader: true, view: view, section: section)
	}

	public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let adapter = adapterForHeaderFooterView(view)
        let _ = adapter?.dispatch(.willDisplay, isHeader: false, view: view, section: section)
	}

	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].headerTitle
	}

	public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return sections[section].footerTitle
	}

	public func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIdx: Int) -> UIView? {
        guard let header = sections[sectionIdx].headerView, let headerView = header.dequeueHeaderFooterForDirector(self) else {
            return nil
        }
		header.dispatch(.dequeue, isHeader: false, view: headerView, section: sectionIdx)
		return headerView
	}

	public func tableView(_ tableView: UITableView, viewForFooterInSection sectionIdx: Int) -> UIView? {
        guard let footer = sections[sectionIdx].footerView, let footerView = footer.dequeueHeaderFooterForDirector(self) else {
            return nil
        }
		footer.dispatch(.dequeue, isHeader: false, view: footerView, section: sectionIdx)
		return footerView
	}

	public func tableView(_ tableView: UITableView, heightForHeaderInSection index: Int) -> CGFloat {
		let height = sections[index].headerView?.dispatch(.headerHeight, isHeader: true, view: nil, section: index)
		return (height as? CGFloat ?? UITableView.automaticDimension)
	}

	public func tableView(_ tableView: UITableView, heightForFooterInSection index: Int) -> CGFloat {
		let height = sections[index].footerView?.dispatch(.footerHeight, isHeader: true, view: nil, section: index)
		return (height as? CGFloat ?? UITableView.automaticDimension)
	}

	public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection index: Int) -> CGFloat {
		let estHeight = sections[index].headerView?.dispatch(.estHeaderHeight, isHeader: true, view: nil, section: index)
		guard let estimatedHeight = estHeight as? CGFloat else {
            let height = sections[index].headerView?.dispatch(.headerHeight, isHeader: true, view: nil, section: index)
            return height as? CGFloat ?? sections[index].unspecifiedHeaderHeight
		}
		return estimatedHeight
	}

	public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection index: Int) -> CGFloat {
		let estHeight = sections[index].footerView?.dispatch(.estFooterHeight, isHeader: true, view: nil, section: index)
		guard let estimatedHeight = estHeight as? CGFloat else {
			let height = sections[index].footerView?.dispatch(.footerHeight, isHeader: true, view: nil, section: index)
            return height as? CGFloat ?? sections[index].unspecifiedFooterHeight
		}
		return estimatedHeight
	}
	
	// MARK: - Edit Cell -
	
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.canEditRow, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? false
	}
	
	public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.commitEdit, model: model, cell: nil, path: indexPath, params: editingStyle)
	}
	
	public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter.dispatchEvent(.editActions, model: model, cell: nil, path: indexPath, params: nil) as? [UITableViewRowAction]
	}
	
	// MARK: - Rows Reordering -
	
	public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.canMoveRow, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? false
	}

	public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: sourceIndexPath)
		adapter.dispatchEvent(.moveRow, model: model, cell: nil, path: sourceIndexPath, params: destinationIndexPath)
	}
	
	// MARK: - Row Indentation -
	
	public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.indentLevel, model: model, cell: nil, path: indexPath, params: nil) as? Int) ?? 1
	}
	
	// MARK: - Prefetching -
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		cellAdaptersForIndexPaths(indexPaths).forEach { group in
			group.adapter.dispatchEvent(.prefetch, model: group.models, cell: nil, path: nil, params: group.indexPaths)
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		cellAdaptersForIndexPaths(indexPaths).forEach { group in
			group.adapter.dispatchEvent(.cancelPrefetch, model: group.models, cell: nil, path: nil, params: group.indexPaths)
		}
	}
	
	// MARK: - Other -
	
	@available(iOS 11.0, *)
	public func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
		let (model, adapter) = self.context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.shouldSpringLoad, model: model, cell: nil, path: indexPath) as? Bool) ?? true
	}

	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.tapOnAccessory , model: model, cell: nil, path: indexPath, params: nil)
	}

	public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.willSelect, model: model, cell: nil, path: indexPath, params: nil) as? IndexPath) ?? indexPath
	}

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		guard let action = adapter.dispatchEvent(.tap, model: model, cell: nil, path: indexPath, params: nil) as? TableAdapterCellAction else {
			return
		}
		switch action {
		case .none:
			break
		case .deselect:
			tableView.deselectRow(at: indexPath, animated: false)
		case .deselectAnimated:
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}

	public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.willDeselect, model: model, cell: nil, path: indexPath, params: nil) as? IndexPath)
	}

	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.didDeselect, model: model, cell: nil, path: indexPath, params: nil)
	}

	public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.willBeginEdit, model: model, cell: nil, path: indexPath, params: nil)
	}

	public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		guard let indexPath = indexPath else { return }
        if let (model, adapter) = cachedContext(forItemAt: indexPath, removeFromCache: false) {
            adapter.dispatchEvent(.didEndEdit, model: model, cell: nil, path: indexPath, params: nil)
        }
	}

	public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.editStyle, model: model, cell: nil, path: indexPath, params: nil) as? UITableViewCell.EditingStyle) ?? .none
	}

	public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		let (model, adapter) = context(forItemAt: indexPath)
		return adapter.dispatchEvent(.deleteConfirmTitle, model: model, cell: nil, path: indexPath, params: nil) as? String
	}

	public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.editShouldIndent, model: model, cell: nil, path: nil, params: nil) as? Bool) ?? true
	}

	public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		let (model, adapter) = context(forItemAt: sourceIndexPath)
		return (adapter.dispatchEvent(.moveAdjustDestination, model: model, cell: nil, path: sourceIndexPath, params: proposedDestinationIndexPath) as? IndexPath) ?? proposedDestinationIndexPath
	}

	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let result = cachedContext(forItemAt: indexPath, removeFromCache: false)
        let _ = adapterForCell(cell)?.dispatchEvent(.endDisplay, model: result?.model, cell: cell, path: indexPath, params: nil)
	}

	public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.shouldShowMenu, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? false
	}

	public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.canPerformMenuAction, model: model, cell: nil, path: indexPath, params: action, sender) as? Bool) ?? true
	}

	public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
		let (model, adapter) = context(forItemAt: indexPath)
		let _ = adapter.dispatchEvent(.performMenuAction, model: model, cell: nil, path: indexPath, params: action, sender)
	}

	public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.shouldHighlight, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? true
	}

	public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.didHighlight, model: model, cell: nil, path: indexPath, params: nil)
	}

	public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.didUnhighlight, model: model, cell: nil, path: indexPath, params: nil)
	}

	public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.canFocus, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? true
	}

	@available(iOS 11, *)
	public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let (model, adapter) = context(forItemAt: indexPath)
		return adapter.dispatchEvent(.leadingSwipeActions, model: model, cell: nil, path: indexPath, params: nil) as? UISwipeActionsConfiguration
	}

	@available(iOS 11.0, *)
	public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let (model, adapter) = context(forItemAt: indexPath)
		return adapter.dispatchEvent(.trailingSwipeActions, model: model, cell: nil, path: indexPath, params: nil) as? UISwipeActionsConfiguration
	}

	// MARK: - Section Indexes -

	public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		let indexes = sections.compactMap({ $0.indexTitle })
		guard !indexes.isEmpty else {
			return nil
		}
		return indexes
	}

	public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return sections.firstIndex(where: { $0.indexTitle == title }) ?? 0
	}

	// MARK: - UIScrollViewDelegate -

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollViewEvents.didScroll?(scrollView)
	}

	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		scrollViewEvents.willBeginDragging?(scrollView)
	}

	public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		scrollViewEvents.willEndDragging?(scrollView,velocity,targetContentOffset)
	}

	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		scrollViewEvents.endDragging?(scrollView,decelerate)
	}

	public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		return (scrollViewEvents.shouldScrollToTop?(scrollView) ?? true)
	}

	public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
		scrollViewEvents.didScrollToTop?(scrollView)
	}

	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		scrollViewEvents.willBeginDecelerating?(scrollView)
	}

	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		scrollViewEvents.endDecelerating?(scrollView)
	}

	public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return scrollViewEvents.viewForZooming?(scrollView)
	}

	public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		scrollViewEvents.willBeginZooming?(scrollView,view)
	}

	public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
		scrollViewEvents.endZooming?(scrollView,view,scale)
	}

	public func scrollViewDidZoom(_ scrollView: UIScrollView) {
		scrollViewEvents.didZoom?(scrollView)
	}

	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		scrollViewEvents.endScrollingAnimation?(scrollView)
	}

	public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
		scrollViewEvents.didChangeAdjustedContentInset?(scrollView)
	}


}
