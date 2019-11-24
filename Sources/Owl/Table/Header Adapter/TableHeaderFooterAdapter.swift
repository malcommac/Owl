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

// MARK: - TableHeaderFooterAdapterProtocol -

public protocol TableHeaderFooterAdapterProtocol {
    var modelCellType: Any.Type { get }
    
    func registerHeaderFooterViewForDirector(_ director: TableDirector) -> String
    func dequeueHeaderFooterForDirector(_ director: TableDirector) -> UITableViewHeaderFooterView?
    
    @discardableResult
    func dispatch(_ event: TableSectionEvents, isHeader: Bool, view: UIView?, section: Int) -> Any?
}

public extension TableHeaderFooterAdapterProtocol {
    
    var modelCellIdentifier: String {
        return String(describing: modelCellType)
    }
    
}

// MARK: - TableHeaderFooterAdapter -

open class TableHeaderFooterAdapter<View: UITableViewHeaderFooterView>: TableHeaderFooterAdapterProtocol {
    
    // MARK: - Public Properties -
    
    /// This is the view type.
    public var modelCellType: Any.Type = View.self

    /// This is the identifier of the view. You can change it before dequeueing it
    /// but by default is set to the name of the class used as `View` itself.
    public var reusableViewIdentifier: String
    
    /// This is the source used to load the header/footer view. By default the value
    /// is set to `.fromXib(name: nil, bundle: nil)` which means the view UI is inside
    /// a view with the same name of the class itself inside bundle where the class is set.
    public var reusableViewLoadSource: ReusableViewLoadSource
    
    // Events you can assign to monitor the header/footer of a section.
    public var events = HeaderFooterEventsSubscriber()
    
    // MARK: - Initialization -
    
    public init(_ configuration: ((TableHeaderFooterAdapter) -> ())? = nil) {
        self.reusableViewIdentifier = String(describing: View.self)
        self.reusableViewLoadSource = .fromXib(name: nil, bundle: nil)
        configuration?(self)
    }
    
    // MARK: - Helper Function s-
    
    public func registerHeaderFooterViewForDirector(_ director: TableDirector) -> String {
        let id = reusableViewIdentifier//View.reusableViewIdentifier()
        guard director.headerFooterReuseIdentifiers.contains(id) == false else {
            return id
        }
        registerReusableViewAsType(forDirector: director)
        return id
    }
    
    func registerReusableViewAsType(forDirector director: TableDirector) {
        switch reusableViewLoadSource {
        case .fromStoryboard:
            fatalError("Cannot load header/footer from storyboard. Use another source (xib/class) instead.")
            
        case .fromXib(let name, let bundle):
            let srcBundle = (bundle ?? Bundle.init(for: View.self))
            let srcNib = UINib(nibName: (name ?? reusableViewIdentifier), bundle: srcBundle)
            director.table?.register(srcNib, forHeaderFooterViewReuseIdentifier: reusableViewIdentifier)
            
        case .fromClass:
            director.table?.register(View.self, forHeaderFooterViewReuseIdentifier: reusableViewIdentifier)

        }
    }
    
    public func dequeueHeaderFooterForDirector(_ director: TableDirector) -> UITableViewHeaderFooterView? {
        return director.table?.dequeueReusableHeaderFooterView(withIdentifier: reusableViewIdentifier)
    }
    
    @discardableResult
    public func dispatch(_ event: TableSectionEvents, isHeader: Bool, view: UIView?, section: Int) -> Any? {
        switch event {
        case .dequeue:
            events.dequeue?(HeaderFooterEvent(header: isHeader, view: view, at: section))
            
        case .headerHeight:
            return events.height?(HeaderFooterEvent(header: true, view: view, at: section))
            
        case .footerHeight:
            return events.height?(HeaderFooterEvent(header: false, view: view, at: section))
            
        case .estHeaderHeight:
            return events.estimatedHeight?(HeaderFooterEvent(header: true, view: view, at: section))
            
        case .estFooterHeight:
            return events.estimatedHeight?(HeaderFooterEvent(header: false, view: view, at: section))
            
        case .endDisplay:
            events.endDisplay?(HeaderFooterEvent(header: false, view: view, at: section))
            
        case .willDisplay:
            events.willDisplay?(HeaderFooterEvent(header: false, view: view, at: section))
            
        }
        return nil
    }
    
}
