//
//  File.swift
//  
//
//  Created by Chocoford on 2023/8/25.
//

import Foundation
import TrickleCore

extension TrickleWebRepository {
    func createPaymentLink(workspaceID: WorkspaceData.ID, payload: API.CreatePaymentLinkPayload) async throws -> PaymentLinkData {
        try await call(endpoint: API.createPaymentLink(workspaceID: workspaceID, payload: payload))
    }
    
    @available(*, deprecated, message: "use TrickleECSWebRepository.createStripePortalSession insetead")
    func createStripePortalSession(workspaceID: WorkspaceData.ID) async throws -> PaymentLinkData {
        try await call(endpoint: API.createStripePortalSession(workspaceID: workspaceID))
    }
    
    @available(*, deprecated, message: "use TrickleECSWebRepository.getSubscriptionPlans insetead")
    func getSubscriptionPlans(workspaceID: WorkspaceData.ID) async throws -> AnyStreamable<SubscriptionPlanData> {
        try await call(endpoint: API.getSubscriptionPlans(workspaceID: workspaceID))
    }
    
    @available(*, deprecated, message: "use TrickleECSWebRepository.getSubscriptionUpcomingInvoices insetead")
    func getSubscriptionStatus(workspaceID: WorkspaceData.ID) async throws -> SubscriptionStatusData? {
        try await call(endpoint: API.getSubscriptionStatus(workspaceID: workspaceID))
    }
    
    @available(*, deprecated, message: "use TrickleECSWebRepository.getSubscriptionUpcomingInvoices insetead")
    func getSubscriptionUpcomingInvoices(workspaceID: WorkspaceData.ID, query: API.GetSubscriptionUpcomingInvoicesQuery) async throws -> SubscriptionUpcomingInvoicesData {
        try await call(endpoint: API.getSubscriptionUpcomingInvoices(workspaceID: workspaceID, query: query))
    }
}


extension TrickleECSWebRepository {
    func createStripePortalSession(workspaceID: WorkspaceData.ID) async throws -> PaymentLinkData {
        try await call(endpoint: API.createStripePortalSession(workspaceID: workspaceID))
    }
    
    func getSubscriptionPlans(workspaceID: WorkspaceData.ID) async throws -> AnyStreamable<SubscriptionPlanData> {
        try await call(endpoint: API.getSubscriptionPlans(workspaceID: workspaceID))
    }
    
    func getSubscriptionStatus(workspaceID: WorkspaceData.ID) async throws -> SubscriptionStatusData? {
        try await call(endpoint: API.getSubscriptionStatus(workspaceID: workspaceID))
    }
    
    func getSubscriptionUpcomingInvoices(workspaceID: WorkspaceData.ID, query: API.GetSubscriptionUpcomingInvoicesQuery) async throws -> SubscriptionUpcomingInvoicesData {
        try await call(endpoint: API.getSubscriptionUpcomingInvoices(workspaceID: workspaceID, query: query))
    }
}
