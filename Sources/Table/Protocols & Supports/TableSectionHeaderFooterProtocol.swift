//
//  TableSectionHeaderFooterProtocol.swift
//  FlowKit2
//
//  Created by dan on 10/03/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
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
