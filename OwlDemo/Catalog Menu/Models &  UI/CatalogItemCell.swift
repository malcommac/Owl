//
//  CatalogItemCell.swift
//  Example
//
//  Created by dan on 28/03/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class CatalogItemCell: UITableViewCell {

    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var shortDescLabel: UILabel!
	@IBOutlet public var iconImageView: UIImageView!

	public var item: CatalogItem? {
		didSet {
            titleLabel.text = item?.title ?? "-"
            shortDescLabel.text = item?.shortDesc ?? "-"
			iconImageView.image = item?.icon
		}
	}

}
