//
//  File.swift
//  
//
//  Created by Chocoford on 2023/5/21.
//

import Foundation
import TrickleCore

extension TrickleWebRepository.API {
    struct ACKTrickleCommentsPayload: Codable {
        let memberID: MemberData.ID
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }
}
