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

public protocol CollectionHeaderFooterAdapterProtocol {
    var modelCellType: Any.Type { get }
    
    func registerHeaderFooterViewForDirector(_ director: CollectionDirector, kind: String) -> String
    func dequeueHeaderFooterForDirector(_ director: CollectionDirector, type: String, indexPath: IndexPath) -> UICollectionReusableView?
    
    @discardableResult
	func dispatch(_ event: CollectionSectionEvents, isHeader: Bool, view: UIView?, section: CollectionSection?, index: Int) -> Any?
}

public extension CollectionHeaderFooterAdapterProtocol {
    
    var modelCellIdentifier: String {
        return String(describing: modelCellType)
    }
    
}

public class CollectionHeaderFooterAdapter<View: UICollectionReusableView>: CollectionHeaderFooterAdapterProtocol {
    
    /// This is the cell type used to dequeue the model. You should not alter it.
    public var modelCellType: Any.Type = View.self
    
    /// This is the identifier of the view. You can change it before dequeueing it
    /// but by default is set to the name of the class used as `View` itself.
    public var viewReuseIdentifier: String
    
    /// This is the source used to load the header/footer view. By default the value
    /// is set to `.fromXib(name: nil, bundle: nil)` which means the view UI is inside
    /// a view with the same name of the class itself inside bundle where the class is set.
    public var viewLoadSource: ReusableViewLoadSource
    
    /// Events you can subscribe for header/footer instances.
    public var events = EventsSubscriber()
	
	public init(_ configuration: ((CollectionHeaderFooterAdapter) -> ())? = nil) {
        self.viewReuseIdentifier = String(describing: View.self)
        self.viewLoadSource = .fromStoryboard
		configuration?(self)
	}
    
    public func dequeueHeaderFooterForDirector(_ director: CollectionDirector, type: String, indexPath: IndexPath) -> UICollectionReusableView? {
        return director.collection?.dequeueReusableSupplementaryView(ofKind: type, withReuseIdentifier: viewReuseIdentifier, for: indexPath)
    }
    
    public func registerHeaderFooterViewForDirector(_ director: CollectionDirector, kind: String) -> String {
        if  (kind == UICollectionView.elementKindSectionHeader && director.headerReuseIDs.contains(viewReuseIdentifier)) ||
            (kind == UICollectionView.elementKindSectionFooter && director.footerReuseIDs.contains(viewReuseIdentifier)) {
            return viewReuseIdentifier
        }
        
        let collection = director.collection
        switch viewLoadSource {
        case .fromStoryboard:
            break
            
        case .fromXib(let name, let bundle):
            let nib = UINib(nibName: name ?? viewReuseIdentifier, bundle: bundle)
            collection?.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: viewReuseIdentifier)
            
        case .fromClass:
            collection?.register(View.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: viewReuseIdentifier)
            
        }
        
        return viewReuseIdentifier
    }
    
	public func dispatch(_ event: CollectionSectionEvents, isHeader: Bool, view: UIView?, section: CollectionSection?, index: Int) -> Any? {
        switch event {
        case .dequeue:
			events.dequeue?(Event(isHeader: isHeader, view: view, section: section, index: index))
            
        case .referenceSize:
            return events.referenceSize?(Event(isHeader: isHeader, view: view, section: section, index: index))
            
        case .didDisplay:
            events.didDisplay?(Event(isHeader: isHeader, view: view, section: section, index: index))
            
        case .endDisplay:
            events.endDisplay?(Event(isHeader: isHeader, view: view, section: section, index: index))
            
        case .willDisplay:
            events.willDisplay?(Event(isHeader: isHeader, view: view, section: section, index: index))
            
        }
        return nil
    }
    
    
}
