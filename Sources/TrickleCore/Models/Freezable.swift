//
//  Freezable.swift
//
//
//  Created by Dove Zachary on 2023/9/11.
//

import Foundation

public enum Freezable<T> {
    case frozen(data: T)
    case fresh(data: T)
    
    var data: T {
        switch self {
            case .frozen(let data):
                return data
            case .fresh(let data):
                return data
        }
    }
}

extension Freezable: Equatable where T : Equatable {
    public static func == (lhs: Freezable<T>, rhs: Freezable<T>) -> Bool {
        lhs.data == rhs.data
    }
}
