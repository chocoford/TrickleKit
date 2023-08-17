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
    
    struct MemberOnlyQuery: Codable {
        public let memberID: String
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }
    
}


