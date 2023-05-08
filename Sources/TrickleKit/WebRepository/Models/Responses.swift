//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/17.
//

import Foundation

extension TrickleWebRepository.API {
    struct CreateCommentResponseData: Codable {
        let comment: CommentData
    }
    
    struct CreateWorkspaceResponseData: Codable {
        let workspace: WorkspaceData
    }
    
    struct CreateWorkspaceInvitationResponseData: Codable {
        let workspaceInvitation: WorkspaceInvitationData
    }
    struct UpdateWorkspaceResponseData: Codable {
        let workspaceID: Int // WorkspaceData.ID
        let domain: String
        let name: String
        let logo: String
        let allowedEmailDomains: [String]
        
        enum CodingKeys: String, CodingKey {
            case workspaceID = "workspaceId"
            case domain, name, logo
            case allowedEmailDomains
        }
    }
}
