//
//  Extensions.swift
//  PuzzleGame
//
//  Created by Nignesh on 2016-12-15.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableArray {
    
    func containsView(tile : UIView) -> Bool {

        for item in self {
            let item = item as? UIView
            if item?.center == tile.center {
                return true
            }
        }
        return false
    }
}
