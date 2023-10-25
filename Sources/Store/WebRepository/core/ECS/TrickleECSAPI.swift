//
//  File.swift
//  
//
//  Created by Chocoford on 2023/10/18.
//

import Foundation
import CFWebRepositoryProvider
import TrickleCore


extension TrickleECSWebRepository {
    enum API {
        case createCheckoutSession(workspaceID: WorkspaceData.ID, payload: CreateCheckoutSessionPayload)
        case createStripePortalSession(workspaceID: WorkspaceData.ID)
        case getSubscriptionPlans(workspaceID: WorkspaceData.ID)
        case getSubscriptionStatus(workspaceID: WorkspaceData.ID)
        case getSubscriptionUpcomingInvoices(workspaceID: WorkspaceData.ID, query: GetSubscriptionUpcomingInvoicesQuery)
        case getWorkspaceFeatures(workspaceID: WorkspaceData.ID)
    }
}

extension TrickleECSWebRepository.API: APICall {
    var path: String {
        switch self {
            case .createCheckoutSession(let workspaceID, _):
                return "/subs/v1/workspaces/\(workspaceID)/checkoutSession"
            case .createStripePortalSession(let workspaceID):
                return "/subs/v1/workspaces/\(workspaceID)/stripe/portalSession"
            case .getSubscriptionPlans:
                return "/subs/v1/plans/available"
            case .getSubscriptionStatus(let workspaceID):
                return "/subs/v1/workspaces/\(workspaceID)/subscriptions/active"
            case .getSubscriptionUpcomingInvoices(let workspaceID, _):
                return "/subs/v1/workspaces/\(workspaceID)/invoices/upcoming"
            case .getWorkspaceFeatures(let workspaceID):
                return "/v1/workspaces/\(workspaceID)/features"
        }
    }
    
    var gloabalQueryItems: Codable? {
        struct TrickleWebAPIQuery: Codable {
            var version: Int = Int(Date().timeIntervalSince1970 * 1000)
            var apiVersion: Int = 2
        }
        return TrickleWebAPIQuery()
    }

    var queryItems: Codable? {
        switch self {
            case .getSubscriptionPlans(let workspaceID):
                struct Query: Codable {
                    var workspaceId: String
                }
                return Query(workspaceId: workspaceID)
                
            case .getSubscriptionUpcomingInvoices(_, let query):
                return query
                
            default:
                return nil
        }
    }
    
    var method: APIMethod {
        switch self {
            case .createCheckoutSession,
                    .createStripePortalSession:
                return .post
                
            default:
                return .get
        }
    }
    var headers: [String: String]? {
        var defaults = [
            "Accept": "application/json, text/plain, */*",
            "trickle-trace-id": UUID().uuidString.replacingOccurrences(of: "-", with: ""),
            "trickle-api-version": "2",
            "google-client-id" : "291824365.1696658399"
        ]
        
        if let token = TrickleAuthMiddleware.shared.token {
            defaults["Authorization"] = "Bearer \(token)"
        }
        
        switch self {
            default:
                switch self.method {
                    case .post, .patch:
                        defaults["Content-Type"] = "application/json"
                    default:
                        break
                }
        }
        
        return defaults
    }
    
    func body() throws -> Data? {
        switch self {
            case .createCheckoutSession(_, let payload):
                return try makeBody(payload: payload)
            default:
                return nil
        }
        
    }
}


