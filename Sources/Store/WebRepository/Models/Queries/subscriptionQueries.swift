//
//  File.swift
//  
//
//  Created by Chocoford on 2023/8/28.
//

import Foundation
import TrickleCore

extension TrickleWebRepository.API {
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
