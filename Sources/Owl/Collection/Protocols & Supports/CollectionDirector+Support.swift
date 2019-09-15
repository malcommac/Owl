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

public extension CollectionDirector {

	/// Define the cell size.
	///
	/// - `default`: standard behaviour (no auto sizing, needs to implement `onGetItemSize` on adapters).
	/// - auto: uses autolayout to calculate the size of the cell. You can provide an
	///				 estimated size of the cell to speed up the calculation.
	///				 Implement preferredLayoutAttributesFitting(_:) method in your cell to evaluate the size.
	/// - explicit: fixed size where each item has the same size
	enum ItemSize {
		case `default`
		case auto(estimated: CGSize)
		case explicit(CGSize)
	}


	// MARK: - Public Supporting Structures -

	struct EventsSubscriber {
		typealias HeaderFooterEvent = (view: UICollectionReusableView, path: IndexPath, table: UICollectionView)

		var layoutDidChange: ((_ old: UICollectionViewLayout, _ new: UICollectionViewLayout) -> UICollectionViewTransitionLayout?)? = nil
		var targetOffset: ((_ proposedContentOffset: CGPoint) -> CGPoint)? = nil
		var moveItemPath: ((_ originalIndexPath: IndexPath, _ proposedIndexPath: IndexPath) -> IndexPath)? = nil

		private var _shouldUpdateFocus: ((_ context: AnyObject) -> Bool)? = nil
		@available(iOS 9.0, *)
		var shouldUpdateFocus: ((_ context: UICollectionViewFocusUpdateContext) -> Bool)? {
			get { return _shouldUpdateFocus }
			set { _shouldUpdateFocus = newValue as? ((AnyObject) -> Bool) }
		}

		private var _didUpdateFocus: ((_ context: AnyObject, _ coordinator: AnyObject) -> Void)? = nil
		@available(iOS 9.0, *)
		var didUpdateFocus: ((_ context: UICollectionViewFocusUpdateContext, _ coordinator: UIFocusAnimationCoordinator) -> Void)? {
			get { return _didUpdateFocus }
			set { _didUpdateFocus = newValue as? ((AnyObject, AnyObject) -> Void) }
		}

		var willDisplayHeader : ((HeaderFooterEvent) -> Void)? = nil
		var willDisplayFooter : ((HeaderFooterEvent) -> Void)? = nil

		var endDisplayHeader : ((HeaderFooterEvent) -> Void)? = nil
		var endDisplayFooter : ((HeaderFooterEvent) -> Void)? = nil
	}

	internal class PrefetchModelsGroup {
		let adapter: 	CollectionCellAdapterProtocol
		var models: 	[ElementRepresentable] = []
		var indexPaths: [IndexPath] = []

		public init(adapter: CollectionCellAdapterProtocol) {
			self.adapter = adapter
		}
	}

}
