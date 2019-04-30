//
//  ContactSingleCell.swift
//  Example
//
//  Created by dan on 03/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class ContactSingleCell: UITableViewCell {
    
    @IBOutlet public var nameLabel: UILabel!
    @IBOutlet public var roleLabel: UILabel!
    @IBOutlet public var emailAddress: UILabel!
    @IBOutlet public var iconImageView: AsyncImageView!
    
    public var item: ContactSingle? {
        didSet {
            guard let item = item else {
                nameLabel.text = ""
                roleLabel.text = ""
                emailAddress.text = ""
                iconImageView.image = nil
                return
            }
            nameLabel.text = item.name
            roleLabel.text = item.position
            emailAddress.text = item.email
            iconImageView.imageFromServerURL(url: item.photo.absoluteString)
        }
    }
    
}

