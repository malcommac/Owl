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

public extension CollectionHeaderFooterAdapter {

	struct Event {

		/// Type of item (footer or header)
		public private(set) var isHeader: Bool
		/// Instance of the view dequeued for this section.
		public private(set) var view: View?

		/// Index of the section.
		public private(set) var sectionIndex: Int
		
		public private(set) var section: CollectionSection?


		/// Initialize a new context (private).
		public init(isHeader: Bool, view: UIView?, section: CollectionSection?, index: Int) {
			self.isHeader = isHeader
			self.view = view as? View
			self.sectionIndex = index
			self.section = section
		}
	}

	struct EventsSubscriber {
		public var dequeue: ((Event) -> Void)? = nil
		public var referenceSize: (((Event)) -> CGSize)? = nil
		public var didDisplay: (((Event)) -> Void)? = nil
		public var endDisplay: (((Event)) -> Void)? = nil
		public var willDisplay: (((Event)) -> Void)? = nil
	}

}

public protocol CollectionSectionHeaderFooterProtocol {
	var section: CollectionSection? { get }

	@discardableResult
	func registerHeaderFooterViewForDirector(_ director: CollectionDirector, type: String) -> String

	@discardableResult
	func dispatch(_ event: CollectionSectionEvents, isHeader: Bool, view: UIView?, section: Int) -> Any?
}

public enum CollectionSectionEvents: Int {
	case dequeue
	case referenceSize
	case didDisplay
	case endDisplay
	case willDisplay
}
