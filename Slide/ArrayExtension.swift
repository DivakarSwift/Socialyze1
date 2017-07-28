//
//  ArrayExtension.swift
//  Slide
//
//  Created by bibek timalsina on 7/28/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation

extension Array {
    func elementAt(index: Int) -> Array.Iterator.Element? {
        if index < self.count && index >= 0 {
            return self[index]
        }
        return nil
    }
}
