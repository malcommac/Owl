//
//  Models.swift
//  Example
//
//  Created by dan on 28/03/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class CatalogItem: ElementRepresentable, Equatable {
	let icon: UIImage
    let title: String
    var shortDesc: String = ""
	let id: String

	public var differenceIdentifier: String {
		return title
	}

	public func isContentEqual(to other: Differentiable) -> Bool {
		guard let other = other as? CatalogItem else { return false }
		return other == self
	}

	public static func == (lhs: CatalogItem, rhs: CatalogItem) -> Bool {
		return lhs.icon == rhs.icon && lhs.title == rhs.title
	}

	init(id: String, icon: UIImage, title: String) {
		self.id = id
		self.icon = icon
		self.title = title
	}

}
