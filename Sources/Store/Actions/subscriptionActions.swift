//
//  subscriptionActions.swift
//
//
//  Created by Chocoford on 2023/8/25.
//

import Foundation
import TrickleCore

public extension TrickleStore {
    func tryCreatePaymentLink(
        workspaceID: WorkspaceData.ID,
        memberID: MemberData.ID,
        priceID: SubscriptionPlanData.PricingData.ID
    ) async throws -> URL {
        let urlString = try await self.webRepositoryClient.createPaymentLink(
            workspaceID: workspaceID,
            payload: .init(memberID: memberID, priceID: priceID)
        )
        
        struct InvalidURL: Error {}
        guard let url = URL(string: urlString.url) else { throw InvalidURL() }
        return url
    }
    
    func tryCreateStripePortalSession(workspaceID: WorkspaceData.ID) async throws -> URL {
        let urlString = try await self.ecsWebRepositoryClient.createStripePortalSession(workspaceID: workspaceID)
        struct InvalidURL: Error {}
        guard let url = URL(string: urlString.url) else { throw InvalidURL() }
        return url
    }
    
    func tryGetSubscriptionPlans(workspaceID: WorkspaceData.ID) async throws -> AnyStreamable<SubscriptionPlanData> {
        return try await self.ecsWebRepositoryClient.getSubscriptionPlans(workspaceID: workspaceID)
    }
    
    func tryGetSubscriptionStatus(workspaceID: WorkspaceData.ID) async throws -> SubscriptionStatusData? {
        return try await self.ecsWebRepositoryClient.getSubscriptionStatus(workspaceID: workspaceID)
    }
    
    func tryGetSubscriptionUpcomingInvoices(
        workspaceID: WorkspaceData.ID,
        memberID: MemberData.ID,
        subscriptionID: SubscriptionStatusData.ID? = nil,
        newPriceID: SubscriptionPlanData.PricingData.ID? = nil,
        quantity: Int? = nil
    ) async throws -> SubscriptionUpcomingInvoicesData {
        return try await self.ecsWebRepositoryClient.getSubscriptionUpcomingInvoices(
            workspaceID: workspaceID,
            query: .init(
                memberID: memberID,
                subscriptionID: subscriptionID,
                newPriceID: newPriceID,
                quantity: quantity)
        )
    }
    
    
}
