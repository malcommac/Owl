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

public protocol TableSectionHeaderFooterProtocol {
	var section: TableSection? { get }

	func registerHeaderFooterViewForDirector(_ director: TableDirector) -> String

	@discardableResult
	func dispatch(_ event: TableSectionEvents, isHeader: Bool, view: UIView?, section: Int, table: UITableView) -> Any?
}

extension UITableViewHeaderFooterView: ReusableCellViewProtocol {
	public static var reusableViewClass: AnyClass {
		return self
	}

	public static var reusableViewSource: ReusableViewSource {
		return .fromXib(name: nil,bundle: nil)
	}

}
