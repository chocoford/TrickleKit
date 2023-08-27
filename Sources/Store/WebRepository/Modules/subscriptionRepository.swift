//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/8/25.
//

import Foundation
import TrickleCore

extension TrickleWebRepository {
    func createPaymentLink(workspaceID: WorkspaceData.ID, payload: API.CreatePaymentLinkPayload) async throws -> PaymentLinkData {
        try await call(endpoint: API.createPaymentLink(workspaceID: workspaceID, payload: payload))
    }
    
    func createStripePortalSession(workspaceID: WorkspaceData.ID) async throws -> PaymentLinkData {
        try await call(endpoint: API.createStripePortalSession(workspaceID: workspaceID))
    }
    
    func getSubscriptionPlans(workspaceID: WorkspaceData.ID) async throws -> AnyStreamable<SubscriptionPlanData> {
        try await call(endpoint: API.getSubscriptionPlans(workspaceID: workspaceID))
    }
    
    func getSubscriptionStatus(workspaceID: WorkspaceData.ID) async throws -> SubscriptionStatusData? {
        try await call(endpoint: API.getSubscriptionStatus(workspaceID: workspaceID))
    }
    
    func getSubscriptionUpcomingInvoices(workspaceID: WorkspaceData.ID, query: API.GetSubscriptionUpcomingInvoicesQuery) async throws -> AnyStreamable<SubscriptionUpcomingInvoiceData> {
        try await call(endpoint: API.getSubscriptionUpcomingInvoices(workspaceID: workspaceID, query: query))
    }
}
