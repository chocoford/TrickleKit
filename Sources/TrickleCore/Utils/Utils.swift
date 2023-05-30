//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/3.
//

import Foundation



public func formDic<T>(payload: [T], id: KeyPath<T, String>) -> [String: T] {
    var dic: [String : T] = [:]
    for item in payload {
        dic[item[keyPath: id]] = item
    }
    return dic
}

public func formBearer(with token: String?) -> String? {
    guard let token = token else { return nil }
    return "Bearer " + token
}
