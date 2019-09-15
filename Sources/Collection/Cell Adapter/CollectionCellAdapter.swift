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

open class CollectionCellAdapter<Model: ElementRepresentable, Cell: ReusableViewProtocol>: CollectionCellAdapterProtocol {

    // MARK: - Public Properties -

    /// This is the model type used to dequeue the model. You should not alter it.
    public var modelType: Any.Type = Model.self
    
    /// This is the cell type used to dequeue the model. You should not alter it.
    public var modelViewType: Any.Type = Cell.self
    
    /// This is the reusable identifier to dequeue cell. By default is set to the same
    /// name of the class used as `Cell` but you can override it before using the adapter itself.
    public var reusableViewIdentifier: String
    
    /// This is the source used to dequeue the cell itself. By default is set to `.fromStoryboard`
    /// and it means the cell UI is searched inside the the director's table.
    /// You can however set it before the first dequeue is made to load it as class or from an external xib.
    public var reusableViewLoadSource: ReusableViewLoadSource
    
	// MARK: - Public Functions -

    // Events you can register.
	public var events = CollectionCellAdapter.EventsSubscriber()

	public init(_ configuration: ((CollectionCellAdapter) -> Void)? = nil) {
        self.reusableViewIdentifier = String(describing: Cell.self)
        self.reusableViewLoadSource = .fromStoryboard
		configuration?(self)
	}
	
	// MARK: - Adapter Helpers Functions -

	public func dequeueCell(inCollection collection: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
		return collection.dequeueReusableCell(withReuseIdentifier: /*Cell.reusableViewIdentifier()*/reusableViewIdentifier, for: indexPath)
	}

	public func registerReusableCellViewForDirector(_ director: CollectionDirector) -> Bool {
		guard director.cellReuseIDs.contains(reusableViewIdentifier) == false else {
			return false
		}
        registerReusableView(forDirector: director)
		director.cellReuseIDs.insert(reusableViewIdentifier)
		return true
	}
    
    
    func registerReusableView(forDirector director: CollectionDirector) {
        switch reusableViewLoadSource {
        case .fromStoryboard:
            break
            
        case .fromXib(let name, let bundle):
            let srcBundle = (bundle ?? Bundle.init(for: Cell.self))
            let srcNib = UINib(nibName: (name ?? reusableViewIdentifier), bundle: srcBundle)
            director.collection?.register(srcNib, forCellWithReuseIdentifier: reusableViewIdentifier)
            
        case .fromClass:
            director.collection?.register(Cell.self, forCellWithReuseIdentifier: reusableViewIdentifier)
            
        }
    }

	public func dispatchEvent(_ kind: CollectionAdapterEventID, model: Any?, cell: ReusableViewProtocol?, path: IndexPath?, params: Any?...) -> Any? {
		switch kind {
		case .dequeue:
			events.dequeue?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .shouldSelect:
			return events.shouldSelect?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .shouldDeselect:
			return events.shouldDeselect?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .didSelect:
			events.didSelect?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .didDeselect:
			events.didDeselect?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .didHighlight:
			events.didHighlight?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .didUnhighlight:
			events.didUnhighlight?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .shouldHighlight:
			return events.shouldHighlight?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .willDisplay:
			events.willDisplay?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .endDisplay:
			events.endDisplay?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .shouldShowEditMenu:
			return events.shouldShowEditMenu?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .canPerformEditAction:
			return events.canPerformEditAction?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .performEditAction:
			return events.performEditAction?(CollectionCellAdapter.Event(element: model, cell: cell, path: path),
				params.first as! Selector,
				params.last as Any)

		case .canFocus:
			return events.canFocus?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .itemSize:
			return events.itemSize?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))

		case .prefetch:
			events.prefetch?(params.first as! [Model], params.last as! [IndexPath])

		case .cancelPrefetch:
			events.cancelPrefetch?(params.first as! [Model], params.last as! [IndexPath])

		case .shouldSpringLoad:
			return events.shouldSpringLoad?(CollectionCellAdapter.Event(element: model, cell: cell, path: path))
			
		}

		return nil
	}
}
