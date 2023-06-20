//
//  tricklePayloads.swift
//  
//
//  Created by Dove Zachary on 2023/5/3.
//

import Foundation
import TrickleCore

extension TrickleWebRepository.API {
    struct CreatePostPayload: Codable {
        var authorMemberID: MemberData.ID
        var blocks: [TrickleData.Block]
        var mentionedMemberIDs: [MemberData.ID]
        var referTrickleIDs: [TrickleData.ID]
        var medias, files: [String]
        
        
        enum CodingKeys: String, CodingKey {
            case authorMemberID = "authorMemberId"
            case blocks
            case mentionedMemberIDs = "mentionedMemberIds"
            case referTrickleIDs = "referTrickleIds"
            case medias, files
        }
        
        init(authorMemberID: MemberData.ID, blocks: [TrickleData.Block], mentionedMemberIDs: [MemberData.ID], referTrickleIDs: [TrickleData.ID], medias: [String], files: [String]) {
            self.authorMemberID = authorMemberID
            self.blocks = blocks
            self.mentionedMemberIDs = mentionedMemberIDs
            self.referTrickleIDs = referTrickleIDs
            self.medias = medias
            self.files = files
        }
    }
    
    
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
