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

// MARK: - Public Supporting Structures -

public extension TableDirector {

	/// Events you can monitor from the director and related to the table
	struct TableEventsHandler {

		var didScroll: ((UIScrollView) -> Void)? = nil
		var endScrollingAnimation: ((UIScrollView) -> Void)? = nil

		var shouldScrollToTop: ((UIScrollView) -> Bool)? = nil
		var didScrollToTop: ((UIScrollView) -> Void)? = nil

		var willBeginDragging: ((UIScrollView) -> Void)? = nil
		var willEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetOffset: UnsafeMutablePointer<CGPoint>) -> Void)? = nil
		var endDragging: ((_ scrollView: UIScrollView, _ willDecelerate: Bool) -> Void)? = nil

		var willBeginDecelerating: ((UIScrollView) -> Void)? = nil
		var endDecelerating: ((UIScrollView) -> Void)? = nil

		// zoom
		var viewForZooming: ((UIScrollView) -> UIView?)? = nil
		var willBeginZooming: ((_ scrollView: UIScrollView, _ view: UIView?) -> Void)? = nil
		var endZooming: ((_ scrollView: UIScrollView, _ view: UIView?, _ scale: CGFloat) -> Void)? = nil
		var didZoom: ((UIScrollView) -> Void)? = nil

		var didChangeAdjustedContentInset: ((UIScrollView) -> Void)? = nil
		
	}

	/// Height of the row
	///
	/// - `default`: both `rowHeight`,`estimatedRowHeight` are set to `UITableViewAutomaticDimension`
	/// - automatic: automatic using autolayout. You can provide a valid estimated value.
	/// - fixed: fixed value. If all of your cells are the same height set it to fixed in order to improve the performance of the table.
	enum RowHeight {
		case `default`
		case auto(estimated: CGFloat)
		case explicit(CGFloat)
	}
	
}

// MARK: - Private Supporting Structures -

internal extension TableDirector {

	class PrefetchModelsGroup {
		let adapter: TableCellAdapterProtocol
		var models: [ElementRepresentable] = []
		var indexPaths: [IndexPath] = []

		init(adapter: TableCellAdapterProtocol) {
			self.adapter = adapter
		}
	}

}
