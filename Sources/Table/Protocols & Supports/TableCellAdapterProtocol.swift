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
