//
//  subscriptionActions.swift
//
//
//  Created by Dove Zachary on 2023/8/25.
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
        guard let url = URL(string: urlString) else { throw InvalidURL() }
        return url
    }
    
    func tryGetSubscriptionPlans(workspaceID: WorkspaceData.ID) async throws -> AnyStreamable<SubscriptionPlanData> {
        return try await self.webRepositoryClient.getSubscriptionPlans(workspaceID: workspaceID)
    }
    
    func tryGetSubscriptionStatus(workspaceID: WorkspaceData.ID) async throws -> SubscriptionStatusData {
        return try await self.webRepositoryClient.getSubscriptionStatus(workspaceID: workspaceID)
    }
}
