//
//  TrickleECSWebRepositoryProvider.swift
//
//
//  Created by Dove Zachary on 2023/10/18.
//

import Foundation
import CFWebRepositoryProvider
import Combine
import OSLog
import TrickleCore

protocol TrickleECSWebRepositoryProvider: WebRepositoryProvider {
    
    func getSubscriptionPlans(workspaceID: WorkspaceData.ID) async throws -> AnyStreamable<SubscriptionPlanData>
    func getSubscriptionStatus(workspaceID: WorkspaceData.ID) async throws -> SubscriptionStatusData?
    func getSubscriptionUpcomingInvoices(workspaceID: WorkspaceData.ID, query: TrickleECSWebRepository.API.GetSubscriptionUpcomingInvoicesQuery) async throws -> SubscriptionUpcomingInvoicesData
}
