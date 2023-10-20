//
//  starsQueries.swift
//  
//
//  Created by Chocoford on 2023/5/2.
//

import Foundation
import TrickleCore

extension TrickleWebRepository.API {
    struct ListStarredTricklesQuery: Codable {
        let memberID: MemberData.ID
        let starredByMemberID: MemberData.ID
        let limit: Int
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case starredByMemberID = "starredByMemberId"
            case limit
        }
    }
}
