//
//  ContactCompanyCell.swift
//  Example
//
//  Created by dan on 03/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class ContactCompanyCell: UITableViewCell {
    
    @IBOutlet public var nameLabel: UILabel!
    @IBOutlet public var emailLabel: UILabel!
    @IBOutlet public var employeersLabel: UILabel!
    @IBOutlet public var shortDescLabel: UILabel!
    @IBOutlet public var companyIcon: AsyncImageView!

    public var item: ContactCompany? {
        didSet {
            guard let item = item else {
                nameLabel.text = ""
                emailLabel.text = ""
                employeersLabel.text = ""
                shortDescLabel.text = ""
                companyIcon.image = nil
                return
            }
            nameLabel.text = item.name
            emailLabel.text = item.email
            employeersLabel.text = String(item.peoples.count)
            shortDescLabel.text = item.shortDescription
            companyIcon.imageFromServerURL(url: item.image.absoluteString)
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.item = nil
    }
    
}

