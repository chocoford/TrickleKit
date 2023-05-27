//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/4.
//

import Foundation

public enum BlockWalkState {
    case `continue`
    case skipChildren
    case done
}

extension Array<TrickleData.Block> {
    public func walk(callback: (TrickleData.Block) -> Bool) {
        for block in self {
            guard callback(block) else { return }
            guard block.blocks?._walk(callback: callback) == true else { return }
        }
    }
    
    func _walk(callback: (TrickleData.Block) -> Bool) -> Bool {
        return self.allSatisfy { block in
            guard callback(block) else { return false }
            return block.blocks?._walk(callback: callback) == true
        }
    }
}
