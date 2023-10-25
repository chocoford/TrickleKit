//
//  TrickleECSWebRepositoryProvider.swift
//
//
//  Created by Chocoford on 2023/10/18.
//

import Foundation
import CFWebRepositoryProvider
import Combine
import OSLog
import TrickleCore

protocol TrickleECSWebRepositoryProvider: WebRepositoryProvider {
    func createStripeCheckoutSession(
        workspaceID: WorkspaceData.ID,
        payload: TrickleECSWebRepository.API.CreateCheckoutSessionPayload
    ) async throws -> PaymentLinkData
    func createStripePortalSession(workspaceID: WorkspaceData.ID) async throws -> PaymentLinkData
    func getSubscriptionPlans(workspaceID: WorkspaceData.ID) async throws -> AnyStreamable<SubscriptionPlanData>
    func getSubscriptionStatus(workspaceID: WorkspaceData.ID) async throws -> SubscriptionStatusData?
    func getSubscriptionUpcomingInvoices(workspaceID: WorkspaceData.ID, query: TrickleECSWebRepository.API.GetSubscriptionUpcomingInvoicesQuery) async throws -> SubscriptionUpcomingInvoicesData
    func getWorkspaceFeatures(workspaceID: WorkspaceData.ID) async throws -> WorkspaceFeatures
}
