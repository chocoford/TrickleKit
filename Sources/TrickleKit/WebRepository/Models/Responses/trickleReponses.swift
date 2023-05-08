//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/3.
//

import Foundation

extension TrickleWebRepository.API {
    struct CopyTrickleResponse: Codable {
        let trickleID: TrickleData.ID
        
        enum CodingKeys: String, CodingKey {
            case trickleID = "trickleId"
        }
    }
}
