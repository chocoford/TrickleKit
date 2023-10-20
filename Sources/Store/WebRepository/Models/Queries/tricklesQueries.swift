//
//  File.swift
//  
//
//  Created by Chocoford on 2023/5/2.
//

import Foundation
import TrickleCore

extension TrickleWebRepository.API {
    struct ListTricklesQuery: Codable {
        var workspaceID: WorkspaceData.ID? = nil
        var receiverID: String? = nil
        var trickleID: TrickleData.ID? = nil
        var memberID: MemberData.ID
        var authorID: MemberData.ID? = nil
        var text: String? = nil
        var until: Date? = nil
        var limit: Int? = nil
        var order: Order? = nil
        var starredByMemberID: MemberData.ID? = nil
        
        enum CodingKeys: String, CodingKey {
            case workspaceID = "workspaceId"
            case receiverID = "receiverIds"
            case trickleID = "trickleId"
            case memberID = "memberId"
            case authorID = "authorId"
            case text, until, limit, order
            case starredByMemberID = "starredByMemberId"
        }
        
        enum Order: Int, Codable {
            case asc = 1 // from old to new
            case desc = -1 // from new to old
        }
    }
    
    struct ListQuery: Codable {
        let until: Date?
        let limit: Int
        let order: Order
        
        enum Order: Int, Codable {
            case asc = 1 // from old to new
            case desc = -1 // from new to old
        }
    }
}
