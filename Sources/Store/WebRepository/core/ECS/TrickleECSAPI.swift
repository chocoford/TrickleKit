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
        case getSubscriptionPlans(workspaceID: WorkspaceData.ID)
        case getSubscriptionStatus(workspaceID: WorkspaceData.ID)
        case getSubscriptionUpcomingInvoices(workspaceID: WorkspaceData.ID, query: GetSubscriptionUpcomingInvoicesQuery)
    }
}

extension TrickleECSWebRepository.API: APICall {
    var path: String {
        switch self {
            case .getSubscriptionPlans:
                return "/subs/v1/plans/available"
            case .getSubscriptionStatus(let workspaceID):
                return "/subs/v1/workspaces/\(workspaceID)/subscriptions/active"
            case .getSubscriptionUpcomingInvoices(let workspaceID, _):
                return "/subs/v1/workspaces/\(workspaceID)/invoices/upcoming"
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
           
            default:
                return .get
        }
    }
    var headers: [String: String]? {
        var defaults = [
            "Accept": "application/json, text/plain, */*",
            "trickle-trace-id": UUID().uuidString.replacingOccurrences(of: "-", with: ""),
            "trickle-api-version": "2",
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
            default:
                return nil
        }
        
    }
}


