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
    
    func shuffle() {
        if count < 2 { return }
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
    
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
