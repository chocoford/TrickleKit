//
//  tricklePayloads.swift
//  
//
//  Created by Dove Zachary on 2023/5/3.
//

import Foundation
import TrickleCore

extension TrickleWebRepository.API {
    struct CopyTricklePayload: Codable {
        let oldReceiverID: GroupData.ID
        let newReceiverID: GroupData.ID
        let memberID: MemberData.ID;
        let afterTrickleID: TrickleData.ID?;
        
        enum CodingKeys: String, CodingKey {
            case oldReceiverID = "oldReceiverId"
            case newReceiverID = "newReceiverId"
            case memberID = "memberId"
            case afterTrickleID = "afterTrickleId"
        }
    }
    
    struct AddTrickleLastViewPayload: Codable {
        let memberID: MemberData.ID
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }
}
