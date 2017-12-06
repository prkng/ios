//
//  Array.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-10.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

extension Array {
    
    mutating func remove <U: Equatable> (_ object: U) {
        for i in stride(from: (self.count-1), through: 0, by: -1) {
            if let element = self[i] as? U {
                if element == object {
                    self.remove(at: i)
                }
            }
        }
    }

    mutating func remove <U: Equatable> (_ objects: [U]) {
        for object in objects {
            for i in stride(from: (self.count-1), through: 0, by: -1) {
                if let element = self[i] as? U {
                    if element == object {
                        self.remove(at: i)
                    }
                }
            }
        }
    }
    
    static func filterNils(_ array: [Element?]) -> [Element] {
        return array.filter { $0 != nil }.map { $0! }
    }

}
