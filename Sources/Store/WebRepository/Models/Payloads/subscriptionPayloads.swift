//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/8/25.
//

import Foundation
import TrickleCore

extension TrickleWebRepository.API {
    struct CreatePaymentLinkPayload: Codable {
        var memberID: MemberData.ID
        var priceID: SubscriptionPlanData.PricingData.ID
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case priceID = "priceId"
        }
    }
}
