//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/7.
//

import Foundation

extension Array {
    public func formDic<T>(_ keyPath: KeyPath<Element, T>) -> [T : Element] {
        var dic: [T : Element] = [:]
        for item in self {
            dic[item[keyPath: keyPath]] = item
        }
        return dic
    }
}
