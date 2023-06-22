//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/17.
//

import Foundation
import TrickleCore

// MARK: - Queries
extension TrickleWebRepository.API {
    struct ListPostsQuery: Codable {
        let workspaceID: String
        let receiverID: String?
        let memberID: String
        let authorID: String?
        let text: String?
        let until: Int?
        let limit: Int?
        let order: Int?
        
        enum CodingKeys: String, CodingKey {
            case workspaceID = "workspaceId"
            case receiverID = "receiverIds"
            case memberID = "memberId"
            case authorID = "authorId"
            case text, until, limit, order
        }
        
        init(workspaceID: String, receiverID: String? = nil, memberID: String, authorID: String? = nil, text: String? = nil, until: Int? = nil, limit: Int? = 10, order: Int? = nil) {
            self.workspaceID = workspaceID
            self.receiverID = receiverID
            self.memberID = memberID
            self.authorID = authorID
            self.text = text
            self.until = until
            self.limit = limit
            self.order = order
        }
    }
    struct ListQuery: Codable {
        let until: Int?
        let limit: Int
        let order: Order
        
        enum Order: Int, Codable {
            case asc = 1 // from old to new
            case desc = -1 // from new to old
        }
    }
    
    public struct ListGroupViewTricklesStatQuery: Codable {
        public let groupBy: GroupBy
        public let filterLogicalOperator: GroupData.ViewInfo.FilterLogicalOperator?
        public let filters: [GroupData.ViewInfo.FilterData]
        
        public struct GroupBy: Codable {
            public let fieldId: GroupData.FieldInfo.ID
            public let type: GroupData.FieldInfo.FieldType
            public let groups: [String]
        }
    }
    
    public struct ListGroupViewTricklesStatStringifiedQuery: Codable {
        public let groupBy: String
        public let filterLogicalOperator: GroupData.ViewInfo.FilterLogicalOperator?
        public let filters: String
        
        public struct GroupBy: Codable {
            public let fieldId: GroupData.FieldInfo.ID
            public let type: GroupData.FieldInfo.FieldType
            public let groups: [String]
        }
    }
    
    public struct ListPinTrickleQuery: Codable {
        public let memberID: String
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }
    
}


