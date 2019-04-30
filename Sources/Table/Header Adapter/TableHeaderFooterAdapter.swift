//
//  TakeHeaderFooterAdapter.swift
//  FlowKit2
//
//  Created by dan on 02/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
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

public class TableHeaderFooterAdapter<View: UITableViewHeaderFooterView>: TableHeaderFooterAdapterProtocol {
    
    // MARK: - Public Properties -
    
    public var modelCellType: Any.Type = View.self
    
    // Events you can assign to monitor the header/footer of a section.
    public var events = HeaderFooterEventsSubscriber()
    
    // MARK: - Initialization -
    
    public init(_ configuration: ((TableHeaderFooterAdapter) -> ())? = nil) {
        configuration?(self)
    }
    
    // MARK: - Helper Function s-
    
    public func registerHeaderFooterViewForDirector(_ director: TableDirector) -> String {
        let id = View.reusableViewIdentifier
        guard director.headerFooterReuseIdentifiers.contains(id) == false else {
            return id
        }
        View.registerReusableView(inTable: director.table, as: .header) // or footer, it's the same for table
        return id
    }
    
    public func dequeueHeaderFooterForDirector(_ director: TableDirector) -> UITableViewHeaderFooterView? {
        let id = View.reusableViewIdentifier
        return director.table?.dequeueReusableHeaderFooterView(withIdentifier: id)
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
