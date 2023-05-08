//
//  ChangeNotifyModel.swift
//  
//
//  Created by Chocoford on 2023/5/7.
//

import Foundation

protocol ChangeEvent {
    associatedtype T
    associatedtype E
    
    var event: E { get set }
    var eventData: T { get set }
}

extension TrickleWebSocket {
    struct ChangeNotifyData: Codable {
        let codes: [String : CodeData]

        struct CodeData: Codable {
            let version: Int
            let latestChangeEvent: LatestChangeEvent
            let trigger: Trigger
        }


        struct Trigger: Codable {
            let trickleTraceID: TrickleData.ID?

            enum CodingKeys: String, CodingKey {
                case trickleTraceID = "trickleTraceId"
            }
        }
    }
}

extension TrickleWebSocket.ChangeNotifyData {
    enum LatestChangeEvent: Codable {
        case workspace(WorkspaceChangeEvent)
        case group(GroupChangeEvent)
        
        // views
        case board(BoardChangeEvent)
        case view(BoardChangeEvent)
        
        // trickles
        case trickle(TrickleChangeEvent)
        case comment(CommentChangeEvent)
        case reaction(BoardChangeEvent)
           
        enum CodingKeys: String, CodingKey {
            case type = "event"
            case data = "eventData"
        }

        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let eventType = try container.decode(EventType.self, forKey: .type)
            
            switch eventType {
                case .board:
                    self = .board(try BoardChangeEvent(from: decoder))
                case .group:
                    self = .group(try GroupChangeEvent(from: decoder))
                case .comment:
                    self = .comment(try CommentChangeEvent(from: decoder))
                case .reaction:
                    self = .reaction(try BoardChangeEvent(from: decoder))
                case .trickle:
                    self = .trickle(try TrickleChangeEvent(from: decoder))
                case .workspace:
                    self = .workspace(try WorkspaceChangeEvent(from: decoder))
                case .view:
                    self = .view(try BoardChangeEvent(from: decoder))
                    
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .board(let x):
                    try container.encode(x)
                case .group(let x):
                    try container.encode(x)
                case .comment(let x):
                    try container.encode(x)
                case .reaction(let x):
                    try container.encode(x)
                case .trickle(let x):
                    try container.encode(x)
                case .workspace(let x):
                    try container.encode(x)
                case .view(let x):
                    try container.encode(x)
            }
        }
    }
}

extension TrickleWebSocket.ChangeNotifyData.LatestChangeEvent {
    enum EventType: Codable {
        case board(BoardEventType)
        case group(ChannelEventType)
        case comment(CommentEventType)
        case reaction(ReactionEventType)
        case trickle(TrickleEventType)
        case workspace(WorkspaceEventType)
        case view(ViewEventType)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let x = try? container.decode(BoardEventType.self) {
                self = .board(x)
                return 
            }
            if let x = try? container.decode(ChannelEventType.self) {
                self = .group(x)
                return
            }
            if let x = try? container.decode(CommentEventType.self) {
                self = .comment(x)
                return
            }
            if let x = try? container.decode(ReactionEventType.self) {
                self = .reaction(x)
                return
            }
            if let x = try? container.decode(TrickleEventType.self) {
                self = .trickle(x)
                return
            }
            if let x = try? container.decode(WorkspaceEventType.self) {
                self = .workspace(x)
                return
            }
            if let x = try? container.decode(ViewEventType.self) {
                self = .view(x)
                return
            }
            throw DecodingError.typeMismatch(CommentChangeEvent.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for LatestChangeEventType"))
        }
    }
    
    enum BoardEventType: String, Codable {
        // board
        case workspaceBoardCreated = "WorkspaceBoardCreated"
        case workspaceBoardUpdated = "WorkspaceBoardUpdated"
        case workspaceBoardDeleted = "WorkspaceBoardDeleted"
        case workspaceBoardReorder = "WorkspaceBoardReorder"
        case workspaceBoardPinsBatchUpdated = "WorkspaceBoardPinsBatchUpdated"
        case workspaceBoardPinDeleted = "WorkspaceBoardPinDeleted"
        case workspaceBoardPinCreated = "WorkspaceBoardPinCreated"
    }
    
    enum ChannelEventType: String, Codable {
        case channelMemberRemoved = "ChannelMemberRemoved"
        case channelMemberAdded = "ChannelMemberAdded"
        case channelRankChanged = "ChannelRankChanged"
        case channelDeleted = "ChannelDeleted"
        case channelCreated = "ChannelCreated"
        case channelUpdated = "ChannelUpdated"
    }

    enum CommentEventType: String, Codable {
        case statusCommentCreated = "StatusCommentCreated"
        case commentCreated = "CommentCreated"
        case commentDeleted = "CommentDeleted"
        case threadsUnreadCountUpdated = "ThreadsUnreadCountUpdated"
    }
    
    enum ReactionEventType: String, Codable {
        case reactionCreated = "ReactionCreated"
        case reactionDeleted = "ReactionDeleted"
        case commentReactionCreated = "CommentReactionCreated"
        case commentReactionDeleted = "CommentReactionDeleted"
    }
    
    enum TrickleEventType: String, Codable {
        // trickle
        case trickleDeleted = "TrickleDeleted"
        case trickleMoved = "TrickleMoved"
        case trickleCreated = "TrickleCreated"
        case trickleUpdated = "TrickleUpdated"
        case trickleViewed = "TrickleViewed"
        case tricklePinned = "TricklePinned"
        case trickleUnpinned = "TrickleUnpinned"
        case tricklePinRankUpdated = "TricklePinRankUpdated"
        case channelPinTrickleRankChanged = "ChannelPinTrickleRankChanged"
        case trickleStarred = "TrickleStarred"
        case trickleUnStarred = "TrickleUnStarred"
        case channelTrickleRankChanged = "ChannelTrickleRankChanged"
    }
    
    enum WorkspaceEventType: String, Codable {
        case memberCreated = "MemberCreated"
        case memberLeft = "MemberLeft"
        case memberSpaceUpdated = "MemberSpaceUpdated"
        case memberUpdated = "MemberUpdated"
        case memberRemoved = "MemberRemoved"
        case workspaceUpdated = "WorkspaceUpdated"
        case workspaceDismissed = "WorkspaceDismissed"
    }
    
    enum ViewEventType: String, Codable {
        case channelFieldUpdated = "ChannelFieldUpdated"
        case channelViewUpdated = "ChannelViewUpdated"
    }
}


extension TrickleWebSocket.ChangeNotifyData.LatestChangeEvent {
    enum WorkspaceChangeEvent: Codable {
//        case created
        case updated(WorkspaceUpdatedEvent)
        
        enum CodingKeys: String, CodingKey {
            case eventType = "event"
        }

        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let eventType = try container.decode(WorkspaceEventType.self, forKey: .eventType)
            
            switch eventType {
                case .memberCreated:
                    self = try .init(from: decoder)
                case .memberLeft:
                    self = try .init(from: decoder)
                case .memberSpaceUpdated:
                    self = try .init(from: decoder)
                case .memberUpdated:
                    self = try .init(from: decoder)
                case .memberRemoved:
                    self = try .init(from: decoder)
                case .workspaceUpdated:
                    self = .updated(try WorkspaceUpdatedEvent(from: decoder))
                case .workspaceDismissed:
                    self = try .init(from: decoder)
            }
        }

        // Not test yet
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
//                case .created:
//                    try container.encode(WorkspaceEventType.trickleDeleted, forKey: .eventType)
                case .updated(let data):
                    try container.encode(WorkspaceEventType.workspaceUpdated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
            }

        }
    }
    
    enum GroupChangeEvent: Codable {
        case created
    }
    
    enum BoardChangeEvent: Codable {
        case created
    }
    
    enum TrickleChangeEvent: Codable {
        case created(TrickleCreatedEvent)
        case updated(TrickleUpdatedEvent)
        case deleted(TrickleDeletedEvent)
        
        enum CodingKeys: String, CodingKey {
            case eventType = "event"
        }

        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let eventType = try container.decode(TrickleEventType.self, forKey: .eventType)
            
            switch eventType {
                case .trickleDeleted:
                    self = .deleted(try TrickleDeletedEvent(from: decoder))
                case .trickleMoved:
                    self = try .init(from: decoder)
                case .trickleCreated:
                    self = .created(try TrickleCreatedEvent(from: decoder))
                case .trickleUpdated:
                    self = .updated(try TrickleUpdatedEvent(from: decoder))
                case .trickleViewed:
                    self = try .init(from: decoder)
                case .tricklePinned:
                    self = try .init(from: decoder)
                case .trickleUnpinned:
                    self = try .init(from: decoder)
                case .tricklePinRankUpdated:
                    self = try .init(from: decoder)
                case .channelPinTrickleRankChanged:
                    self = try .init(from: decoder)
                case .trickleStarred:
                    self = try .init(from: decoder)
                case .trickleUnStarred:
                    self = try .init(from: decoder)
                case .channelTrickleRankChanged:
                    self = try .init(from: decoder)
            }
        }

        // Not test yet
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
                case .created(let data):
                    try container.encode(TrickleEventType.trickleCreated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .updated(let data):
                    try container.encode(TrickleEventType.trickleUpdated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .deleted(let data):
                    try container.encode(TrickleEventType.trickleDeleted, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
            }
        }
    }
    
    enum CommentChangeEvent: Codable {
        case created(CommentCreatedEvent)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(CommentCreatedEvent.self) {
                self = .created(x)
                return
            }
            throw DecodingError.typeMismatch(CommentChangeEvent.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for TrickleChangeEvent"))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .created(let x):
                    try container.encode(x)
            }
        }
    }
}

// MARK: - Workspace Change Events
extension TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.WorkspaceChangeEvent {
    struct WorkspaceUpdatedEvent: Codable, ChangeEvent {
        var event: TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.WorkspaceEventType
        var eventData: EventData
        
        struct EventData: Codable {
            var workspaceID: WorkspaceData.ID
            var memberID: MemberData.ID
            var broadcastToRoom: Bool
            var workspaceInfo: [String : AnyDictionaryValue]
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case memberID = "memberId"
                case broadcastToRoom, workspaceInfo
            }
        }
    }
}

// MARK: - Board Change Events
extension TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.BoardChangeEvent {
    
}

// MARK: - Board Change Events
extension TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.BoardChangeEvent {
    
}

// MARK: - Trickles Change Events
extension TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.TrickleChangeEvent {
    struct TrickleCreatedEvent: Codable, ChangeEvent {
        var event: TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.TrickleEventType
        var eventData: EventData
        
        struct EventData: Codable {
            let workspaceID, channelID, trickleID: String
            let afterTrickleID: String?
            let trickleInfo: TrickleData
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case channelID = "channelId"
                case trickleID = "trickleId"
                case afterTrickleID = "afterTrickleId"
                case trickleInfo
            }
        }
    }
    
    struct TrickleUpdatedEvent: Codable, ChangeEvent {
        var event: TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.TrickleEventType
        var eventData: EventData
        
        struct EventData: Codable {
            let workspaceID, channelID, trickleID: String
            let afterTrickleID: String?
            let trickleInfo: TrickleData
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case channelID = "channelId"
                case trickleID = "trickleId"
                case afterTrickleID = "afterTrickleId"
                case trickleInfo
            }
        }
    }
    
    struct TrickleDeletedEvent: Codable, ChangeEvent {
        var event: TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.TrickleEventType
        var eventData: EventData
        
        struct EventData: Codable {
            let trickleID, workspaceID, receiverID, authorMemberID: String
            let createAt: Date
            let threadID: String?
            
            enum CodingKeys: String, CodingKey {
                case trickleID = "trickleId"
                case workspaceID = "workspaceId"
                case receiverID = "receiverId"
                case authorMemberID = "authorMemberId"
                case createAt
                case threadID = "threadId"
            }
        }
    }
}


// MARK: - Comments Change Events
extension TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.CommentChangeEvent {
    struct CommentCreatedEvent: Codable, ChangeEvent {
        var event = "CommentCreated"
        var eventData: EventData
        
        struct EventData: Codable {
            let workspaceID, trickleID, title: String
            let commentInfo: CommentData
            let files, medias: [String]

            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case trickleID = "trickleId"
                case title, commentInfo, files, medias
            }
        }
    }
}
