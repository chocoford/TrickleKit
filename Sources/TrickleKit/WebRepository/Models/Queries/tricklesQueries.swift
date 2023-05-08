//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/2.
//

import Foundation

extension TrickleWebRepository.API {
    struct ListTricklesQuery: Codable {
        var workspaceID: String? = nil
        var receiverID: String? = nil
        var memberID: String
        var authorID: String? = nil
        var text: String? = nil
        var until: Int? = nil
        var limit: Int? = nil
        var order: Int? = nil
        var starredByMemberID: MemberData.ID? = nil
        
        enum CodingKeys: String, CodingKey {
            case workspaceID = "workspaceId"
            case receiverID = "receiverIds"
            case memberID = "memberId"
            case authorID = "authorId"
            case text, until, limit, order
            case starredByMemberID = "starredByMemberId"
        }
    }
}
