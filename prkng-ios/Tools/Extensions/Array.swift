//
//  Array.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-10.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

extension Array {
    
    mutating func remove <U: Equatable> (object: U) {
        for i in stride(from: self.count-1, through: 0, by: -1) {
            if let element = self[i] as? U {
                if element == object {
                    self.removeAtIndex(i)
                }
            }
        }
    }

}
