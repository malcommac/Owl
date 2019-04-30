//
//  TableAdapterProtocol.swift
//  FlowKit2
//
//  Created by dan on 04/03/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public protocol TableCellAdapterProtocol {

	var modelType: Any.Type { get }
	var modelCellType: Any.Type { get }
	var modelIdentifier: String { get }

	func dequeueCell(inTable: UITableView, at indexPath: IndexPath?) -> UITableViewCell

	@discardableResult
	func registerReusableCellViewForDirector(_ director: TableDirector) -> Bool
    
	@discardableResult
	func dispatchEvent(_ kind: TableAdapterEventID, model: Any?,
					   cell: ReusableCellViewProtocol?,
					   path: IndexPath?,
					   params: Any?...) -> Any?
}

public extension TableCellAdapterProtocol {

	var modelIdentifier: String {
		return String(describing: modelType)
	}

}
