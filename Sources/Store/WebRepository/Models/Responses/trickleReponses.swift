//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/3.
//

import Foundation
import TrickleCore


extension TrickleWebRepository.API {
    struct CopyTrickleResponse: Codable {
        let trickleID: TrickleData.ID
        
        enum CodingKeys: String, CodingKey {
            case trickleID = "trickleId"
        }
    }
}
