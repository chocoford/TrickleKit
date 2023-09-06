//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/8/25.
//

import Foundation

public struct SubscriptionStatusData: Codable, Hashable, Identifiable {
    public var subscriptionID: String
    public var status: Status
    public var priceID: SubscriptionPlanData.PricingData.ID
    public var planID: SubscriptionPlanData.ID
    public var planName: String
    public var currentPeriodEnd: Date

    public var id: String { subscriptionID }
    
    enum CodingKeys: String, CodingKey {
        case subscriptionID = "subscriptionId"
        case status
        case priceID = "priceId"
        case planID = "planId"
        case planName
        case currentPeriodEnd
    }
    
    public enum Status: String, Codable {
        case unpaid
        case active
        @available(*, deprecated, message: "Do not use this directly, use isCancelled instead")
        case cancelled
        @available(*, deprecated, message: "Do not use this directly, use isCancelled instead")
        case canceled
        case trialing
        case pastDue
        
        public var isCancelled: Bool {
            self.rawValue == "cancelled" || self.rawValue == "canceled"
        }
        
        public var isActive: Bool {
            !self.isCancelled && self != .unpaid
        }
    }
}

public struct SubscriptionPlanData: Codable, Hashable, Identifiable {
    public var id: String
    public var name: String
    public var description: String?
    public var features: [FeatureData]
    public var prices: [PricingData]
}

extension SubscriptionPlanData {
    public struct PricingData: Codable, Hashable, Identifiable {
        public var id: String
        public var unitAmount: Double
        public var currency: String
        public var type: PricingType
        public var interval: PricingInterval
        
        enum CodingKeys: String, CodingKey {
            case id
            case unitAmount = "unit_amount"
            case currency, type, interval
        }
        
        public enum PricingType: String, Codable {
            case recurring
        }
        
        public enum PricingInterval: String, Codable {
            case year
            case month
        }
        
    }
    
    public struct FeatureData: Codable, Hashable {
        public var id: Double
        public var name: String
        public var enable: Bool
        public var description: String
        public var tag: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case enable
            case description = "desc"
            case tag
        }
    }
}


public struct PaymentLinkData: Codable, Hashable {
    public var url: String
}

public struct SubscriptionUpcomingInvoicesData: Codable, Hashable {
    public var item: InvoiceData
    
    public struct InvoiceData: Codable, Hashable {
        public var amountDue: Int
        public var dueDate: Date?
        public var currency, status: String
        public var invoicePDF: URL?
        public var created, periodEnd: Date
        public var newProration: Int?
        public var hostedInvoiceURL: URL?
    }
}

