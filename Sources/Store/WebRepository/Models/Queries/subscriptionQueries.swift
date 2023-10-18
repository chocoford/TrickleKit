//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/8/28.
//

import Foundation
import TrickleCore

extension TrickleECSWebRepository.API {
    struct GetSubscriptionUpcomingInvoicesQuery: Codable {
        var memberID: MemberData.ID
        var subscriptionID: SubscriptionPlanData.ID?
        var newPriceID: SubscriptionPlanData.PricingData.ID?
        var quantity: Int?
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case subscriptionID = "subscriptionId"
            case newPriceID = "newPriceId"
            case quantity
        }
    }
}
