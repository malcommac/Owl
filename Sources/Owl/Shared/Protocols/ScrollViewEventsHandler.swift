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

/// Events you can monitor from the director and related to the table
public struct ScrollViewEventsHandler {

	public var didScroll: ((UIScrollView) -> Void)? = nil
	public var endScrollingAnimation: ((UIScrollView) -> Void)? = nil

	public var shouldScrollToTop: ((UIScrollView) -> Bool)? = nil
	public var didScrollToTop: ((UIScrollView) -> Void)? = nil

	public var willBeginDragging: ((UIScrollView) -> Void)? = nil
	public var willEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetOffset: UnsafeMutablePointer<CGPoint>) -> Void)? = nil
	public var endDragging: ((_ scrollView: UIScrollView, _ willDecelerate: Bool) -> Void)? = nil

	public var willBeginDecelerating: ((UIScrollView) -> Void)? = nil
	public var endDecelerating: ((UIScrollView) -> Void)? = nil

	// zoom
	public var viewForZooming: ((UIScrollView) -> UIView?)? = nil
	public var willBeginZooming: ((_ scrollView: UIScrollView, _ view: UIView?) -> Void)? = nil
	public var endZooming: ((_ scrollView: UIScrollView, _ view: UIView?, _ scale: CGFloat) -> Void)? = nil
	public var didZoom: ((UIScrollView) -> Void)? = nil

	public var didChangeAdjustedContentInset: ((UIScrollView) -> Void)? = nil

}
