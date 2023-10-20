//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation

public enum BlockWalkState {
    case `continue`
    case skipChildren
    case done
}

extension [TrickleBlock] {
    public func walk(callback: (Self.Element) -> Bool) {
        for block in self {
            guard callback(block) else { return }
            guard block.blocks?._walk(callback: callback) == true else { return }
        }
    }
    
    func _walk(callback: (Self.Element) -> Bool) -> Bool {
        return self.allSatisfy { block in
            guard callback(block) else { return false }
            return block.blocks?._walk(callback: callback) == true
        }
    }
}
