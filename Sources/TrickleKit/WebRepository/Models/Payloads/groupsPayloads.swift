//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Foundation

extension TrickleWebRepository.API {
    public struct CreateGroupPayload: Codable {
        public var name: String
        public var icon: String?
        public var memberIDs: [MemberData.ID];
        public var isWorkspacePublic: Bool
        public var ownerID: String
        public var channelType: GroupData.ChannelType
        
        enum CodingKeys: String, CodingKey {
            case name, icon
            case memberIDs = "memberIds"
            case isWorkspacePublic
            case ownerID = "ownerId"
            case channelType
        }
    }
    
    public struct UpdateGroupPayload: Codable {
        public var name: String?
        public var icon: String?
        public var isPublic: Bool?
//        public var profile: ProfileInfo?
        public var memberID: String?
//        public var shareSetting: ShareSettingData?
        
        enum CodingKeys: String, CodingKey {
            case name, icon, isPublic
            case memberID = "memberId"
        }
    }
    
    struct AckGroupPayload: Codable {
        public var memberID: String
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }
//
//    public struct ProfileInfo: Codable {
//        public var bgUrl: String
//        public var bio: String
//        public var position: Int
//    }
}
