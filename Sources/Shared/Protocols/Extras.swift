//
//  Extras.swift
//  Owl-iOS
//
//  Created by dan on 05/05/2019.
//  Copyright © 2019 Owl. All rights reserved.
//

import Foundation

internal extension IndexPath {
    
    init?(optionalSection section: Int?, row: Int) {
        guard let section = section else {
            return nil
        }
        self.init(row: row, section: section)
    }
    
}
