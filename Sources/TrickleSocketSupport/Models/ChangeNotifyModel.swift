//
//  ChangeNotifyModel.swift
//  
//
//  Created by Chocoford on 2023/5/7.
//

import Foundation
import TrickleCore

protocol ChangeEvent: Codable {
    associatedtype T
    associatedtype E
    
    var event: E { get set }
    var eventData: T { get set }
}

public struct ChangeNotifyData: Codable {
    public let codes: [String : CodeData]

    public struct CodeData: Codable {
        public let version: Int
        public let latestChangeEvent: LatestChangeEvent
        public let trigger: Trigger
    }


    public struct Trigger: Codable {
        public let trickleTraceID: MemberData.ID?

        enum CodingKeys: String, CodingKey {
            case trickleTraceID = "trickleTraceId"
        }
    }
}

public extension ChangeNotifyData {
    enum LatestChangeEvent: Codable {
        case workspace(WorkspaceChangeEvent)
        case group(GroupChangeEvent)
        
        // views
        case board(BoardChangeEvent)
        case view(ViewChangeEvent)
        
        // trickles
        case trickle(TrickleChangeEvent)
        case comment(CommentChangeEvent)
        case reaction(ReactionChangeEvent)
        
        case subscription(SubscriptionChangeEvent)
           
        enum CodingKeys: String, CodingKey {
            case type = "event"
            case data = "eventData"
        }

        
        public init(from decoder: Decoder) throws {
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
                    self = .reaction(try ReactionChangeEvent(from: decoder))
                case .trickle:
                    self = .trickle(try TrickleChangeEvent(from: decoder))
                case .workspace:
                    self = .workspace(try WorkspaceChangeEvent(from: decoder))
                case .view:
                    self = .view(try ViewChangeEvent(from: decoder))
                case .subscription:
                    self = .subscription(try SubscriptionChangeEvent(from: decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
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
                case .subscription(let x):
                    try container.encode(x)
            }
        }
    }
}

public extension ChangeNotifyData.LatestChangeEvent {
    enum EventType: Codable {
        case board(BoardEventType)
        case group(ChannelEventType)
        case comment(CommentEventType)
        case reaction(ReactionEventType)
        case trickle(TrickleEventType)
        case workspace(WorkspaceEventType)
        case view(ViewEventType)
        case subscription(SubscriptionEventType)
        
        public init(from decoder: Decoder) throws {
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
            if let x = try? container.decode(SubscriptionEventType.self) {
                self = .subscription(x)
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
        case dMUnreadCountUpdated = "DMUnreadCountUpdated"
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
        case trickleUnStarred = "TrickleUnstarred"
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
    
    enum SubscriptionEventType: String, Codable {
        case statusChanged = "SubscriptionStatusChanged"
    }
}

public extension ChangeNotifyData.LatestChangeEvent {
    enum WorkspaceChangeEvent: Codable {
//        case created
        case updated(WorkspaceUpdatedEvent)
        
        enum CodingKeys: String, CodingKey {
            case eventType = "event"
        }

        
        public init(from decoder: Decoder) throws {
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
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
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
        case moved(TrickleMovedEvent)
        case viewed(TrickleViewdEvent)
        case pinRankChanged(TricklePinRankChangedEvent)
        case starred(TrickleStarredEvent)
        case unstarred(TrickleUnstarredEvent)
        
        enum CodingKeys: String, CodingKey {
            case eventType = "event"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let eventType = try container.decode(TrickleEventType.self, forKey: .eventType)
            
            switch eventType {
                case .trickleCreated:
                    self = .created(try TrickleCreatedEvent(from: decoder))
                case .trickleUpdated:
                    self = .updated(try TrickleUpdatedEvent(from: decoder))
                case .trickleMoved:
                    self = .moved(try TrickleMovedEvent(from: decoder))
                case .trickleDeleted:
                    self = .deleted(try TrickleDeletedEvent(from: decoder))
                case .trickleViewed:
                    self = .viewed(try TrickleViewdEvent(from: decoder))
                case .tricklePinned:
                    self = try .init(from: decoder)
                case .trickleUnpinned:
                    self = try .init(from: decoder)
                case .tricklePinRankUpdated:
                    self = try .init(from: decoder)
                case .channelPinTrickleRankChanged:
                    self = .pinRankChanged(try TricklePinRankChangedEvent(from: decoder))
                case .trickleStarred:
                    self = .starred(try TrickleStarredEvent(from: decoder))
                case .trickleUnStarred:
                    self = .unstarred(try TrickleUnstarredEvent(from: decoder))
                case .channelTrickleRankChanged:
                    self = try .init(from: decoder)
            }
        }

        // Not test yet
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
                case .created(let data):
                    try container.encode(TrickleEventType.trickleCreated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .updated(let data):
                    try container.encode(TrickleEventType.trickleUpdated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .moved(let data):
                    try container.encode(TrickleEventType.trickleUpdated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .deleted(let data):
                    try container.encode(TrickleEventType.trickleDeleted, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .viewed(let data):
                    try container.encode(TrickleEventType.trickleViewed, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .pinRankChanged(let data):
                    try container.encode(TrickleEventType.channelPinTrickleRankChanged, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .starred(let data):
                    try container.encode(TrickleEventType.trickleStarred, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .unstarred(let data):
                    try container.encode(TrickleEventType.trickleUnStarred, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
            }
        }
    }
    
    enum CommentChangeEvent: Codable {
        case created(CommentCreatedEvent)
        case deleted(CommentDeletedEvent)
        case statusCommentCreated(StatusCommentCreatedEvent)
        case threadsUnreadCountUpdated(ThreadsUnreadCountUpdatedEvent)
        
        enum CodingKeys: String, CodingKey {
            case eventType = "event"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let eventType = try container.decode(CommentEventType.self, forKey: .eventType)
            
            switch eventType {
                case .commentCreated:
                    self = .created(try CommentCreatedEvent(from: decoder))
                case .commentDeleted:
                    self = .deleted(try CommentDeletedEvent(from: decoder))
                case .statusCommentCreated:
                    self = .statusCommentCreated(try StatusCommentCreatedEvent(from: decoder))
                case .threadsUnreadCountUpdated:
                    self = .threadsUnreadCountUpdated(try ThreadsUnreadCountUpdatedEvent(from: decoder))
                case .dMUnreadCountUpdated:
                    self = .threadsUnreadCountUpdated(try ThreadsUnreadCountUpdatedEvent(from: decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
                case .created(let data):
                    try container.encode(CommentEventType.commentCreated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .deleted(let data):
                    try container.encode(CommentEventType.commentDeleted, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .statusCommentCreated(let data):
                    try container.encode(CommentEventType.statusCommentCreated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .threadsUnreadCountUpdated(let data):
                    try container.encode(CommentEventType.threadsUnreadCountUpdated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
   
            }
        }
    }
    
    enum ReactionChangeEvent: Codable {
        case created(ReactionCreatedEvent)
        case deleted(ReactionDeletedEvent)
        case commentReactionCreated(CommentReactionCreatedEvent)
        case commentReactionDeleted(CommentReactionDeletedEvent)
        
        enum CodingKeys: String, CodingKey {
            case eventType = "event"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let eventType = try container.decode(ReactionEventType.self, forKey: .eventType)
            
            switch eventType {
                case .reactionCreated:
                    self = .created(try ReactionCreatedEvent(from: decoder))
                case .reactionDeleted:
                    self = .deleted(try ReactionDeletedEvent(from: decoder))
                case .commentReactionCreated:
                    self = .commentReactionCreated(try CommentReactionCreatedEvent(from: decoder))
                case .commentReactionDeleted:
                    self = .commentReactionDeleted(try CommentReactionDeletedEvent(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
                case .created(let data):
                    try container.encode(ReactionEventType.reactionCreated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .deleted(let data):
                    try container.encode(ReactionEventType.reactionDeleted, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .commentReactionCreated(let data):
                    try container.encode(ReactionEventType.commentReactionCreated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
                case .commentReactionDeleted(let data):
                    try container.encode(ReactionEventType.commentReactionDeleted, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
            }
        }
    }
    
    enum ViewChangeEvent: Codable {
        case fieldUpdated(GroupFieldUpdatedEvent)
        
        enum CodingKeys: String, CodingKey {
            case eventType = "event"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let eventType = try container.decode(ViewEventType.self, forKey: .eventType)
            
            switch eventType {
                case .channelFieldUpdated:
                    self = try .init(from: decoder)
                case .channelViewUpdated:
                    self = try .init(from: decoder)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
                case .fieldUpdated(let data):
                    try container.encode(ViewEventType.channelFieldUpdated, forKey: .eventType)
                    try data.encode(to: container.superEncoder(forKey: .eventType))
            }
        }
    }
    
    enum SubscriptionChangeEvent: Codable {
        case statusChanged(SubscriptionStatusChangeEvent)
    }
}

// MARK: - Workspace Change Events
public extension ChangeNotifyData.LatestChangeEvent.WorkspaceChangeEvent {
    struct WorkspaceUpdatedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.WorkspaceEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public var workspaceID: WorkspaceData.ID
            public var memberID: MemberData.ID
            public var broadcastToRoom: Bool
            public var workspaceInfo: [String : AnyDictionaryValue]
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case memberID = "memberId"
                case broadcastToRoom, workspaceInfo
            }
        }
    }
}

// MARK: - Board Change Events
public extension ChangeNotifyData.LatestChangeEvent.BoardChangeEvent {
    
}

// MARK: - Trickles Change Events
public extension ChangeNotifyData.LatestChangeEvent.TrickleChangeEvent {
    struct TrickleCreatedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.TrickleEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID, channelID, trickleID: String
            public let afterTrickleID: String?
            public let trickleInfo: TrickleData
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case channelID = "channelId"
                case trickleID = "trickleId"
                case afterTrickleID = "afterTrickleId"
                case trickleInfo
            }
        }
    }
    
    struct TrickleUpdatedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.TrickleEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID, channelID, trickleID: String
            public let afterTrickleID: String?
            public let trickleInfo: TrickleData
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case channelID = "channelId"
                case trickleID = "trickleId"
                case afterTrickleID = "afterTrickleId"
                case trickleInfo
            }
        }
    }
    
    struct TrickleDeletedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.TrickleEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let trickleID, workspaceID, receiverID, authorMemberID: String
            public let createAt: Date
            public let threadID: String?
            
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
    
    struct TrickleMovedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.TrickleEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID: WorkspaceData.ID
            public let channelID, fromChannelID: GroupData.ID
            public let trickleID: TrickleData.ID
            public let afterTrickleID: TrickleData.ID?
            public let trickleInfo: TrickleData
            public let triggerMemberID: MemberData.ID
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case channelID = "channelId"
                case fromChannelID = "fromChannelId"
                case trickleID = "trickleId"
                case afterTrickleID = "afterTrickleId"
                case trickleInfo
                case triggerMemberID = "triggerMemberId"
            }
        }
    }
    
    struct TrickleViewdEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.TrickleEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID: WorkspaceData.ID
            public let memberID: MemberData.ID
            public let trickleID: TrickleData.ID
            public let trickleInfo: TrickleInfo
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case memberID = "memberId"
                case trickleID = "trickleId"
                case trickleInfo
            }
            
            public struct TrickleInfo: Codable {
                public let trickleID: TrickleData.ID
                public let viewedMemberInfo: ViewedMemberInfo

                enum CodingKeys: String, CodingKey {
                    case trickleID = "trickleId"
                    case viewedMemberInfo
                }
                
                public struct ViewedMemberInfo: Codable {
                    public let members: [MemberData]
                    public let counts: Int
                }
            }
        }
    }
    
//    struct TricklePinnedEvent: ChangeEvent {
//        public var event: ChangeNotifyData.LatestChangeEvent.TrickleEventType
//        public var eventData: EventData
//
//        public struct EventData: Codable {
//            let workspaceID: WorkspaceData.ID
//            let memberID: MemberData.ID
//            let trickleID: TrickleData.ID
//            let trickleInfo: TrickleData
//
//            enum CodingKeys: String, CodingKey {
//                case workspaceID = "workspaceId"
//                case memberID = "memberId"
//                case trickleID = "trickleId"
//                case trickleInfo
//            }
//        }
//    }
    
    struct TricklePinRankChangedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.TrickleEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID: WorkspaceData.ID
            public let channelID: GroupData.ID
            public let trickleID: TrickleData.ID
            public let afterTrickleID: TrickleData.ID
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case channelID = "channelId"
                case trickleID = "trickleId"
                case afterTrickleID = "afterTrickleId"
            }
        }
    }
    
    struct TrickleStarredEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.TrickleEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID: WorkspaceData.ID
            public let trickleID: TrickleData.ID
            public let memberID: MemberData.ID
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case trickleID = "trickleId"
                case memberID = "memberId"
            }
        }
    }
    
    struct TrickleUnstarredEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.TrickleEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID: WorkspaceData.ID
            public let trickleID: TrickleData.ID
            public let memberID: MemberData.ID
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case trickleID = "trickleId"
                case memberID = "memberId"
            }
        }
    }
}


// MARK: - Comments Change Events
public extension ChangeNotifyData.LatestChangeEvent.CommentChangeEvent {
    struct CommentCreatedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.CommentEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID, trickleID, title: String
            public let commentInfo: CommentData
            public let files, medias: [String]

            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case trickleID = "trickleId"
                case title, commentInfo, files, medias
            }
        }
    }
    struct CommentDeletedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.CommentEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID: WorkspaceData.ID
            public let trickleID: TrickleData.ID
            public let commentID: CommentData.ID

            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case trickleID = "trickleId"
                case commentID = "commentId"
            }
        }
    }
    struct StatusCommentCreatedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.CommentEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID, trickleID, title: String
            public let commentInfo: CommentData
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case trickleID = "trickleId"
                case title, commentInfo
            }
        }
    }
    struct ThreadsUnreadCountUpdatedEvent: Codable, ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.CommentEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public var workspaceID: WorkspaceData.ID
            public var memberID: MemberData.ID
            public var broadcastToMember: Bool
            public var threadsUnreadCount: Int
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case memberID = "memberId"
                case broadcastToMember
                case threadsUnreadCount
            }
        }
    }
    
    struct DMUnreadCountUpdatedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.CommentEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
           
        }
    }
}

// MARK: - Reactions Change Events
public extension ChangeNotifyData.LatestChangeEvent.ReactionChangeEvent {
    struct ReactionCreatedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.ReactionEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public var reactionInfo: ReactionData
            public var title: String
            public var trickleID: TrickleData.ID
            public var triggerMemberID: MemberData.ID
            public var workspaceID: WorkspaceData.ID
            
            enum CodingKeys: String, CodingKey {
                case reactionInfo
                case title
                case trickleID = "trickleId"
                case triggerMemberID = "triggerMemberId"
                case workspaceID = "workspaceId"
            }
        }
    }
    
    struct ReactionDeletedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.ReactionEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public var workspaceID: WorkspaceData.ID
            public var trickleID: TrickleData.ID
            public var reactionID: ReactionData.ID
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case trickleID = "trickleId"
                case reactionID = "reactionId"
            }
        }
    }
    
    struct CommentReactionCreatedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.ReactionEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public var reactionInfo: ReactionData
            public var title: String
            public var trickleID: TrickleData.ID
            public var commentID: CommentData.ID
            public var workspaceID: WorkspaceData.ID
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case trickleID = "trickleId"
                case commentID = "commentId"
                case title, reactionInfo
            }
        }
    }
    
    struct CommentReactionDeletedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.ReactionEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public var workspaceID: WorkspaceData.ID
            public var trickleID: TrickleData.ID
            public var commentID: CommentData.ID
            public var reactionID: ReactionData.ID
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case trickleID = "trickleId"
                case commentID = "commentId"
                case reactionID = "reactionId"
            }
        }
    }
}

// MARK: - View Change Events
public extension ChangeNotifyData.LatestChangeEvent.ViewChangeEvent {
    struct GroupFieldUpdatedEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.ViewEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            
        }
    }
}

// MARK: - Subsctiption Change Events
public extension ChangeNotifyData.LatestChangeEvent.SubscriptionChangeEvent {
    struct SubscriptionStatusChangeEvent: ChangeEvent {
        public var event: ChangeNotifyData.LatestChangeEvent.SubscriptionEventType
        public var eventData: EventData
        
        public struct EventData: Codable {
            public let workspaceID: WorkspaceData.ID
            public let status: SubscriptionStatusData.Status
            
            enum CodingKeys: String, CodingKey {
                case workspaceID = "workspaceId"
                case status
            }
        }
    }
}
