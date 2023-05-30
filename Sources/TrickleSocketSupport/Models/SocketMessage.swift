//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/28.
//

import Foundation
import TrickleCore

public enum MessageType {
    case connect
    
    case hello(data: HelloData)
    
    case subscribeWorkspaces(data: SubscribeWorkspacesPayload)
    
    case joinRoom(data: RoomData)
    case roomStatus(data: RoomData)
    case leaveRoom(data: RoomData)
}

public enum MessageAction: String, Codable {
    case message
    case notification
    case version
}

public struct MessageMeta: Codable {
    public let seqNo: Int?
    public let version: String
    
    public init(seqNo: Int?, version: String) {
        self.seqNo = seqNo
        self.version = version
    }
}

public struct Message<T: Codable, P: Codable>: Codable {
    public let id: String
    public let authorization: String?
    public let action: MessageAction
    public let path: P
    public let data: T?
    public let meta: MessageMeta?
    
    public init(id: String? = nil, authorization: String? = nil, action: MessageAction, path: P, data: T? = nil, meta: MessageMeta? = nil) {
        self.id = id ?? UUID().uuidString
        self.authorization = authorization
        self.action = action
        self.path = path
        self.data = data
        self.meta = .init(seqNo: nil, version: "SwifyTrickle \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)")
    }
}

public enum IncomingMessagePath: String, Codable {
    case connectSuccess = "connect_success"
    case helloAck = "connect_hello_ack"
    case joinRoomAck = "join_room_ack"
    case roomMembers = "room_members"
    
    /// actions
    case sync
    case changeNotify = "change_notify"
}
public typealias IncomingEmptyMessage = IncomingMessage<EmptyData>
public typealias IncomingMessage<T: Codable> = Message<T, IncomingMessagePath>

public enum OutgoingMessagePath: String, Codable {
    case connect
    case hello = "connect_hello"
    case subscribe
    case joinRoom = "join_room"
    case roomStatus = "room_status"
    case leaveRoom = "leave_room"
}
public typealias OutgoingEmptyMessage = OutgoingMessage<EmptyData>
public typealias OutgoingMessage<T: Codable> = Message<T, OutgoingMessagePath>



public extension MessageType {
    struct HelloData: Codable {
        public let userID: String
        
        public init(userID: String) {
            self.userID = userID
        }
        
        enum CodingKeys: String, CodingKey {
            case userID = "userId"
        }
    }
    
    struct RoomData: Codable {
        public let roomID, memberID: String
        public enum Status: String, Codable {
            case online
            case offline
        }
        public let status: Status
        
        public init(roomID: String, memberID: String, status: Status) {
            self.roomID = roomID
            self.memberID = memberID
            self.status = status
        }
        
        enum CodingKeys: String, CodingKey {
            case roomID = "roomId"
            case memberID = "memberId"
            case status
        }
    }
    
    struct SubscribeWorkspacesPayload: Codable {
        public let workspaceIds: [String]
        public let userId: String
        
        public init(workspaceIds: [String], userId: String) {
            self.workspaceIds = workspaceIds
            self.userId = userId
        }
    }
}

// MARK: - Incoming Socket Data
public struct ConnectData: Codable {
    public var connectionID: String
    public let helloInterval, deadInterval, maxRetryConnection, retryConnectionInterval: Int
    public let roomStatusHelloInterval, roomStatusDeadInterval, joinRoomMaxRetryCounts, joinRoomMaxRetryInterval: Int
    public let listRoomInterval: Int
    
    enum CodingKeys: String, CodingKey {
        case connectionID = "connectionId"
        case helloInterval = "hello_interval"
        case deadInterval = "dead_interval"
        case maxRetryConnection = "max_retry_connection"
        case retryConnectionInterval = "retry_connection_interval"
        case roomStatusHelloInterval = "room_status_hello_interval"
        case roomStatusDeadInterval = "room_status_dead_interval"
        case joinRoomMaxRetryCounts = "join_room_max_retry_counts"
        case joinRoomMaxRetryInterval = "join_room_max_retry_interval"
        case listRoomInterval = "list_room_interval"
    }
}

public struct HelloAckData: Codable {
    public let connectionID: String
    
    enum CodingKeys: String, CodingKey {
        case connectionID = "connectionId"
    }
}

public struct RoomMembers: Codable {
    public struct RoomMembersUpdate: Codable {
        public let memberID: String
        public let roomID: String
        public let type: String
        
        public init(memberID: String, roomID: String, type: String) {
            self.memberID = memberID
            self.roomID = roomID
            self.type = type
        }
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case roomID = "roomId"
            case type
        }
    }
    public let all: [String : [String]]
    public let update: RoomMembersUpdate
    
    public init(all: [String : [String]], update: RoomMembersUpdate) {
        self.all = all
        self.update = update
    }
}

// MARK: - EventData
public struct EventData: Codable {
    public let trickleID, title, authorMemberID: String
    public let mentionedMemberIDS: [String]
    public let receiverType, receiverID, workspaceID: String
    public let createAt: Int
    public let threadID, prevTrickleID, appMemberID: String?
    
    enum CodingKeys: String, CodingKey {
        case trickleID = "trickleId"
        case title
        case authorMemberID = "authorMemberId"
        case mentionedMemberIDS = "mentionedMemberIds"
        case receiverType
        case receiverID = "receiverId"
        case workspaceID = "workspaceId"
        case createAt
        case threadID = "threadId"
        case prevTrickleID = "prevTrickleId"
        case appMemberID = "appMemberId"
    }
}
