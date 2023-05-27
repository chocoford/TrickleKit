//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/17.
//

import Foundation
import TrickleCore
 
protocol FormDataPayload: Codable {
    var boundary: String { get set }
}
 
extension FormDataPayload {
    var data: Data {
        var data = Data()
        
        for (key, value) in self.dictionary {
            if ["boundary", "data"].contains(key) { continue }
            
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            if #available(macOS 12.3, iOS 15.4, *) {
                data.append("Content-Disposition: form-data; name=\"\(key.codingKey.stringValue)\"\r\n\r\n".data(using: .utf8)!)
            } else {
                // Fallback on earlier versions
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n".data(using: .utf8)!)
            }
            if let stringValue = value as? String,
               let d = stringValue.data(using: .utf8) {
                data.append(d)
            } else if let stringValue = value as? Bool,
                      let d = stringValue.description.data(using: .utf8) {
                data.append(d)
            }
        }
        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }
}

extension TrickleWebRepository.API {
    struct CreateWorkspacePayload: Codable {
        let name, userID, userName: String
        let workspaceType: WorkspaceType
        let logo: String

        enum WorkspaceType: String, Codable {
            case team, personal
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case userID = "userId"
            case userName, workspaceType, logo
        }
    }
    
    struct UpdateWorkspacePayload: Codable {
        let name: String
        let logo: String
        let memberID: String
        let allowedEmailDomains: [String]
        
        enum CodingKeys: String, CodingKey {
            case name, logo
            case memberID = "memberId"
            case allowedEmailDomains
        }
    }
    
    struct CreateWorkspaceInvitationPayload: Codable {
        let workspaceID: String
        let memberID: String
        let role: MemberData.Role
        let allowedEmailDomains: [String]
        let allowedEmails: [String]
        let needConfirm: Bool
        
        enum CodingKeys: String, CodingKey {
            case workspaceID = "workspaceId"
            case memberID = "memberId"
            case role, allowedEmailDomains, allowedEmails, needConfirm
        }
    }
    
    struct SendEmailPayload: Codable {
        var url: String
        var memberID: MemberData.ID
        var sendTo: [String]
        
        enum CodingKeys: String, CodingKey {
            case url
            case memberID = "memberId"
            case sendTo
        }
    }
    
    
    
    struct CreateCommentPayload: Codable {
        let authorMemberID: String
        let mentionedMemberIDs: [String];
        let blocks: [TrickleData.Block];
        let quoteCommentID: String?;
        
        enum CodingKeys: String, CodingKey {
            case authorMemberID = "authorMemberId"
            case mentionedMemberIDs = "mentionedMemberIds"
            case blocks
            case quoteCommentID = "quoteCommentId"
        }
    }
    
    struct SortStringifyPayload: Codable {
        let memberID: String
        let limit: Int
//        let filters: Never?
        let sorts: String
        let groupByFilters: String?
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case limit, sorts, groupByFilters
//            case filters
        }
    }
    
    struct CreateReactionPayload: Codable {
        let memberID: String
        let reactionCode: String
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case reactionCode
        }
    }
    struct MemberOnlyPayload: Codable {
        let memberID: String
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }
    
    struct PinTricklePayload: Codable {
        public let memberID: String
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }

    struct StarTricklePayload: Codable {
        public let memberID: String
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }
    
    struct UnstarTricklePayload: Codable {
        public let memberID: String
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }
}
