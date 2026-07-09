//
//  NSObject+Extension.swift
//  WorkerHandbook
//
//  Created by QUENV1 on 22/12/2022.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

func removeDuplicates<T: Hashable>(from array: [T]) -> [T] {
    var uniqueArray = [T]()
    var seenElements = Set<T>()

    for element in array {
        if !seenElements.contains(element) {
            uniqueArray.append(element)
            seenElements.insert(element)
        }
    }

    return uniqueArray
}
