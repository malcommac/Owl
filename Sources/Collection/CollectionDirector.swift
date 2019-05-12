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

open class CollectionDirector: NSObject,
	UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {

	//MARK: - Private Properties -

	/// Registered adapters for this collection manager
    private var cellAdapters = [String: CollectionCellAdapterProtocol]()
    
    /// Registered adapters for header/footer
    private var headerFooterAdapters = [String: CollectionHeaderFooterAdapterProtocol]()

	/// Registered cell identifiers
	internal var cellReuseIDs = Set<String>()

	/// Registered header identifiers
	internal var headerReuseIDs = Set<String>()

	/// Registered footer identifiers
	internal var footerReuseIDs = Set<String>()
    
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

	//MARK: - Public Properties -

	/// Managed collection view
	public private(set) weak var collection: UICollectionView?

	/// Sections of the collection
	public private(set) var sections = [CollectionSection]()
    
    
    /// Return first section.
    public var firstSection: CollectionSection? {
        return sections.first
    }
    
    /// Return last section.
    public var lastSection: CollectionSection? {
        return sections.last
    }
    
	/// Events subscriber
	public var events = CollectionDirector.EventsSubscriber()

	/// ScrollView delegate events subscriber
	public var scrollEvents = ScrollViewEventsHandler()

	//MARK: - Initialization -

	/// Initialize a new collection manager with given collection instance.
	///
	/// - Parameter collection: instance of the collection to manage.
	public init(_ collection: UICollectionView) {
		super.init()
		self.collection = collection
		self.collection?.dataSource = self
		self.collection?.delegate = self
		//self.collection?.dragDelegate = self.dragDrop
		//self.collection?.dropDelegate = self.dragDrop
	}

	// MARK: - Register Adapters -

	/// Register a sequence of adapter for the table. If an adapter is already
	/// registered request will be ignored automatically.
	///
	/// - Parameter adapters: adapters to register.
	public func registerAdapters(_ adapters: [CollectionCellAdapterProtocol]) {
		adapters.forEach {
			registerAdapter($0)
		}
	}

	/// Register a new adapter for the table.
	/// An adapter rapresent the entity composed by the pair <model, cell>
	/// used by the directory to manage their representation inside the table itself.
	/// If adapter is already registered it will be ignored automatically.
	///
	/// - Parameter adapter: adapter instance to register.
	public func registerAdapter(_ adapter: CollectionCellAdapterProtocol) {
		guard cellAdapters[adapter.modelIdentifier] == nil else {
			return
		}
		cellAdapters[adapter.modelIdentifier] = adapter
		adapter.registerReusableCellViewForDirector(self)
	}
    
    // MARK: - Register Header/Footer Adapters -
    
    /// Register a new adapters for header and footer custom view.
    ///
    /// - Parameter adapters: adapters.
    public func registerHeaderFooterAdapters(_ adapters: [CollectionHeaderFooterAdapterProtocol]) {
        adapters.forEach {
            registerHeaderFooterAdapter($0)
        }
    }
    
    /// Register header/footer for header/footer custom view.
    ///
    /// - Parameter adapter: adapter.
    /// - Returns: registered identifier.
    @discardableResult
    public func registerHeaderFooterAdapter(_ adapter: CollectionHeaderFooterAdapterProtocol) -> String {
        let id = adapter.modelCellIdentifier
        guard headerFooterAdapters[id] == nil else {
            return id
        }
        headerFooterAdapters[id] = adapter
        let _ = adapter.registerHeaderFooterViewForDirector(self, kind: UICollectionView.elementKindSectionHeader)
        let _ = adapter.registerHeaderFooterViewForDirector(self, kind: UICollectionView.elementKindSectionFooter)
        return id
    }
    
    /// Return the adapter used to render specific header/footer at given indexPath.
    ///
    /// - Parameters:
    ///   - kind: kind of header/footer.
    ///   - indexPath: index path.
    /// - Returns: adapter if any
    internal func adapterForHeaderFooter(_ kind: String, indexPath: IndexPath) -> CollectionHeaderFooterAdapterProtocol? {
        let adapter: CollectionHeaderFooterAdapterProtocol?
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            adapter = sections[indexPath.section].headerView
        case UICollectionView.elementKindSectionFooter:
            adapter = sections[indexPath.section].footerView
        default:
            return nil
        }
        return adapter
    }

	// MARK: - Public Functions -

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

	/// Change the content of the table.
	///
	/// - Parameter models: array of models to set.
	public func set(sections newSections: [CollectionSection]) {
		sections = newSections
        sections.forEach { $0.director = self }
	}
    
    /// Return section with given unique identifier.
    ///
    /// - Parameter uuid: unique identifier.
    /// - Returns: `TableSection`
    public func section(_ uuid: String) -> CollectionSection? {
        return sections.first(where: { $0.identifier == uuid })
    }

	/// Create a new section, append it at the end of the sections list and insert in it passed models.
	///
	/// - Parameter models: models of the section
	/// - Returns: added section instance
	@discardableResult
	public func add(elements: [ElementRepresentable]) -> CollectionSection {
		let section = CollectionSection(elements: elements)
        section.director = self
		sections.append(section)
		return section
	}

	/// Add a new section at given index.
	///
	/// - Parameters:
	///   - section: section to insert.
	///   - index: destination index; if `nil` it will be append at the end of the list.
	public func add(section: CollectionSection, at index: Int? = nil) {
        section.director = self
		guard let index = index, index < sections.count else {
			sections.append(section)
			return
		}
		sections.insert(section, at: index)
	}

	/// Add a list of the section starting at given index.
	///
	/// - Parameters:
	///   - sections: sections to append
	///   - index: destination index; if `nil` it will be append at the end of the list.
	public func add(sections newSections: [CollectionSection], at index: Int? = nil) {
        newSections.forEach { $0.director = self }
		guard let i = index, i < sections.count else {
			sections.append(contentsOf: newSections)
			return
		}
		sections.insert(contentsOf: newSections, at: i)
	}

	/// Remove all sections from the collection.
	///
	/// - Returns: number of removed sections.
	@discardableResult
	public func removeAll(keepingCapacity kp: Bool = false) -> Int {
		let count = sections.count
        let removedSections = sections
        
        for removedSection in removedSections.enumerated() { // used to fill temporary cache if needed
            removedSection.element.removeAll()
            removedSection.element.director = nil
        }
        
		sections.removeAll(keepingCapacity: kp)
		return count
	}

	/// Remove section at index from the collection.
	/// If index is not valid it does nothing.
	///
	/// - Parameter index: index of the section to remove.
	/// - Returns: removed section
	@discardableResult
	public func remove(section index: Int) -> CollectionSection? {
		guard index < sections.count else {
			return nil
		}
        let removedSection = sections.remove(at: index)
        removedSection.director = nil
		return removedSection
	}

	/// Remove sections at given indexes.
	/// Invalid indexes are ignored.
	///
	/// - Parameter indexes: indexes to remove.
	/// - Returns: removed sections.
	@discardableResult
	public func remove(sectionsAt indexes: IndexSet) -> [CollectionSection] {
		var removed = [CollectionSection]()
		indexes.reversed().forEach {
			if $0 < self.sections.count {
				removed.append(sections.remove(at: $0))
			}
		}
        removed.forEach { $0.director = nil }
		return removed
	}

	/// Get section at given index.
	///
	/// - Parameter index: index, if invalid produces `nil` result.
	/// - Returns: section instance if index is valid, `nil` otherwise.
	public func sectionAt(_ index: Int) -> CollectionSection? {
		guard index < sections.count else {
			return nil
		}
		return sections[index]
	}
	
	// MARK: - Reload -
	
	public func reload(afterUpdate update: ((CollectionDirector) -> Void)? = nil,
					   completion: (() -> Void)? = nil) {
		guard let update = update else {
			collection?.reloadData()
			return
		}
        
        isInReloadSession = true
		
		let oldSections = self.sections.map { $0.copy() }
		update(self)
		let changeset = StagedChangeset(source: oldSections, target: sections)
		
		collection?.reload(using: changeset, setData: {
			self.sections = $0
		})
        
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                completion()
            }
        }
        
        isInReloadSession = false
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                completion()
            }
        }
	}

	// MARK: - Private Methods -

	internal func context(forItemAt indexPath: IndexPath) -> (ElementRepresentable, CollectionCellAdapterProtocol) {
		let modelInstance = sections[indexPath.section].elements[indexPath.row]
		guard let adapter = cellAdapters[modelInstance.modelClassIdentifier] else {
			fatalError("No register adapter for model '\(modelInstance.modelClassIdentifier)' at (\(indexPath.section),\(indexPath.row))")
		}
		return (modelInstance, adapter)
	}

    /// Cached context return temporary cached element to provide rationalle values for didEnd events which works with removed elements.
    ///
    /// - Parameters:
    ///   - path: path of the element.
    ///   - removeFromCache: `true` to remove element cache after request. By default is `true`.
    /// - Returns: cached element and adapter if any.
    internal func cachedContext(forItemAt path: IndexPath, removeFromCache: Bool = true) -> (model: ElementRepresentable, adapter: CollectionCellAdapterProtocol)? {
        guard let modelInstance = cachedItems[path], let adapter = self.cellAdapters[modelInstance.modelClassIdentifier]  else {
            return nil
        }
        if removeFromCache {
            cachedItems.removeValue(forKey: path)
        }
        return (modelInstance, adapter)
    }
    
}

public extension CollectionDirector {

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sections.count
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return sections[section].elements.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let (model, adapter) = context(forItemAt: indexPath)
		let cell = adapter.dequeueCell(inCollection: collectionView, at: indexPath)
		adapter.dispatchEvent(.dequeue, model: model, cell: cell, path: indexPath, params: nil)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.willDisplay, model: model, cell: cell, path: indexPath, params: nil)
	}

	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let result = cachedContext(forItemAt: indexPath, removeFromCache: false)
        let _ = adapterForCell(cell)?.dispatchEvent(.endDisplay, model: result?.model, cell: cell, path: indexPath, params: nil)
	}

	// MARK: - Select -

	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.didDeselect, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? true
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.didSelect, model: model, cell: nil, path: indexPath, params: nil)
	}

	// MARK: - Deselect -

	func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.shouldDeselect, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? true
	}

	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.didDeselect, model: model, cell: nil, path: indexPath, params: nil)
	}

	// MARK: - Highlight -

	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.didDeselect, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? true
	}

	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.didHighlight, model: model, cell: nil, path: indexPath, params: nil)
	}

	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.didUnhighlight, model: model, cell: nil, path: indexPath, params: nil)
	}

	// MARK: - Layout -

	func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
		guard let layout = events.layoutDidChange?(fromLayout,toLayout) else {
			return UICollectionViewTransitionLayout.init(currentLayout: fromLayout, nextLayout: toLayout)
		}
		return layout
	}

	func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
		guard let path = events.moveItemPath?(originalIndexPath,proposedIndexPath) else {
			return proposedIndexPath
		}
		return path
	}

	func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
		guard let offset = events.targetOffset?(proposedContentOffset) else {
			return proposedContentOffset
		}
		return offset
	}

	// MARK: - Contextual Menu -

	func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.shouldShowEditMenu, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? false
	}

	// MARK: - Actions -

	func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.canPerformEditAction, model: model, cell: nil, path: indexPath, params: action, sender) as? Bool) ?? true
	}

	func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
		let (model, adapter) = context(forItemAt: indexPath)
		adapter.dispatchEvent(.performEditAction, model: model, cell: nil, path: indexPath, params: action, sender)
	}

	// MARK: - Spring Load -

	@available(iOS 11.0, *)
	func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.shouldSpringLoad, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? true
	}

	// MARK: - Focus -

	func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
		let (model, adapter) = context(forItemAt: indexPath)
		return (adapter.dispatchEvent(.canFocus, model: model, cell: nil, path: indexPath, params: nil) as? Bool) ?? true
	}

	func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
		guard let update = events.shouldUpdateFocus?(context) else {
			return true
		}
		return update
	}

	func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		events.didUpdateFocus?(context, coordinator)
	}

	// MARK: - Header/Footer -

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let adapter = adapterForHeaderFooter(kind, indexPath: indexPath)
        let view = adapter?.dequeueHeaderFooterForDirector(self, type: kind, indexPath: indexPath) ?? UICollectionReusableView()
        let _ = adapter?.dispatch(.dequeue, isHeader: (kind == UICollectionView.elementKindSectionHeader), view: view, section: sections[indexPath.section], index: indexPath.section)
        return view
    }

	func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        let adapter = adapterForHeaderFooter(elementKind, indexPath: indexPath)
		let _ = adapter?.dispatch(.willDisplay, isHeader: true, view: view, section: sections[indexPath.section], index: indexPath.section)
		view.layer.zPosition = 0
	}

	func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        let adapter = adapterForHeaderFooter(elementKind, indexPath: indexPath)
        let _ = adapter?.dispatch(.endDisplay, isHeader: true, view: view, section: sections[indexPath.section], index: indexPath.section)
	}

	func headerFooterForSection(ofType type: String, at indexPath: IndexPath) -> CollectionHeaderFooterAdapterProtocol? {
		switch type {
		case UICollectionView.elementKindSectionHeader:
			return sections[indexPath.section].headerView
		case UICollectionView.elementKindSectionFooter:
			return sections[indexPath.section].footerView
		default:
			return nil
		}
	}

	// MARK: - Prefetch -

	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		adaptersForIndexPaths(indexPaths).forEach {
			$0.adapter.dispatchEvent(.prefetch, model: nil, cell: nil, path: nil, params: $0.models, $0.indexPaths)
		}
	}

	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		adaptersForIndexPaths(indexPaths).forEach {
			$0.adapter.dispatchEvent(.cancelPrefetch, model: nil, cell: nil, path: nil, params: $0.models, $0.indexPaths)
		}
	}

	// MARK: - Private Functions -

	internal func adaptersForIndexPaths(_ paths: [IndexPath]) -> [PrefetchModelsGroup] {
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
    
    internal func adapterForCell(_ cell: UICollectionViewCell) -> CollectionCellAdapterProtocol? {
        return cellAdapters.first(where: { item in
            return item.value.modelCellType == type(of: cell)
        })?.value
    }

	// MARK: - ScrollView Delegate -

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.scrollEvents.didScroll?(scrollView)
	}

	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.scrollEvents.willBeginDragging?(scrollView)
	}

	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		self.scrollEvents.willEndDragging?(scrollView,velocity,targetContentOffset)
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		self.scrollEvents.endDragging?(scrollView,decelerate)
	}

	func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		return (self.scrollEvents.shouldScrollToTop?(scrollView) ?? true)
	}

	func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
		self.scrollEvents.didScrollToTop?(scrollView)
	}

	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		self.scrollEvents.willBeginDecelerating?(scrollView)
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.scrollEvents.endDecelerating?(scrollView)
	}

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.scrollEvents.viewForZooming?(scrollView)
	}

	func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		self.scrollEvents.willBeginZooming?(scrollView,view)
	}

	func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
		self.scrollEvents.endZooming?(scrollView,view,scale)
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.scrollEvents.didZoom?(scrollView)
	}

	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		self.scrollEvents.endScrollingAnimation?(scrollView)
	}

	func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
		self.scrollEvents.didChangeAdjustedContentInset?(scrollView)
	}

}
