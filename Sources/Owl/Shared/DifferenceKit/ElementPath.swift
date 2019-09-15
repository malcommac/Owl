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

import Foundation

public struct ElementPath: Hashable {
	public var element: Int
	public var section: Int
	
	@inlinable
	public init(element: Int, section: Int) {
		self.element = element
		self.section = section
	}
}
