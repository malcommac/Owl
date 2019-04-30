//
//  EmojiCell.swift
//  Example
//
//  Created by dan on 04/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class EmojiCell: UICollectionViewCell {
    
    @IBOutlet public var emojiLabel: UILabel!
    
    public var emoji: String? {
        didSet {
            emojiLabel.text = emoji ?? ""
        }
    }
    
}
