//
//  TrickleStore.swift
//  
//
//  Created by Chocoford on 2023/3/17.
//

import SwiftUI
import CFWebRepositoryProvider
import TrickleCore

public enum TrickleStoreError: LocalizedError {
    case lodableError(_ error: LoadableError)
    case unexpected(_ error: Error)
    
    case unauthorized
    case invalidWorkspaceID(_ workspaceID: WorkspaceData.ID?)
    case invalidGroupID(_ groupID: GroupData.ID?)
    case invalidViewID(_ viewID: GroupData.ViewInfo.ID?)
    case invalidTrickleID(_ trickleID: TrickleData.ID?)
    case invalidReactionID(_ reactionID: ReactionData.ID?)
    case invalidMemberID(_ memberID: MemberData.ID?)
    case pinError(_ error: PinError)
    case starError(_ error: StarError)
    case apnsError(_ error: APNsError)
    case aiAgentError(_ error: AIAgentError)
    
    public var errorDescription: String {
        switch self {
            case .lodableError(let error):
                return "Loadable error: \(error.localizedDescription)"
                
            case .unexpected(let error):
                return "Unexpected error: \(error.localizedDescription)"
                
            case .unauthorized:
                return "Unauthorized."
                
            case .invalidWorkspaceID(let workspaceID):
                return "Invalid workspace ID(\(workspaceID ?? "nil"))."
            case .invalidGroupID(let groupID):
                return "Invalid groupID(\(groupID ?? "nil"))"
            case .invalidViewID(let viewID):
                return "Invalid viewID(\(viewID ?? "nil"))"
            case .invalidTrickleID(let trickleID):
                return "Invalid trickleID(\(trickleID ?? "nil"))"
            case .invalidReactionID(let reactionID):
                return "Invalid reactionID(\(reactionID ?? "nil"))"
            case .invalidMemberID(let memberID):
                return "Invalid memberID(\(memberID ?? "nil"))"
            case .pinError(let error):
                return error.errorDescription
            case .starError(let error):
                return error.errorDescription
            case .apnsError(let error):
                return error.errorDescription
            case .aiAgentError(let error):
                return error.errorDescription
        }
    }
    
    public init(_ error: Error) {
        if let error = error as? TrickleStoreError {
            self = error
        } else if let error = error as? LoadableError {
            self = .lodableError(error)
        } else {
            self = .unexpected(error)
        }
    }
}



@MainActor
public class TrickleStore: ObservableObject {
    internal var webRepositoryClient: TrickleWebRepository
    internal var socket: TrickleWebSocket
    internal lazy var aiAgentSocket: TrickleAIAgentSocketClient = {
        TrickleAIAgentSocketClient(onEvents: self.onAIAgentSocketEvents)
    }()
    internal var apnsHelper: TrickleAPNsHelper

    public init(storeHTTPClient: TrickleWebRepository = .default) {
        self.webRepositoryClient = storeHTTPClient
        self.apnsHelper = .init(storeHTTPClient.logLevel)
        self.socket = TrickleWebSocket(handlers: { message in
            
        })
    }
    
    @Published public var deviceToken: String? = nil
    
    @Published public var userInfo: Loadable<UserInfo?> = .notRequested {
        didSet {
            if case .loaded(let value) = userInfo, let token = value?.token, let userID = value?.user.id {
                self.socket.initSocket(token: token, userID: userID)
            } else {
                self.socket.close()
            }
        }
    }
    
    @Published public var allWorkspaces: Loadable<AnyStreamable<WorkspaceData>> = .notRequested
    // TODO: Be the source of truth
    public var workspaces: [WorkspaceData.ID : WorkspaceData] {
        formDic(payload: allWorkspaces.value?.items ?? [], id: \.workspaceID)
    }
    
    @AppStorage("currentWorkspaceID") public var currentWorkspaceID: WorkspaceData.ID? = nil
    
    public var currentWorkspace: WorkspaceData? {
        guard let workspaceID = currentWorkspaceID else { return nil }
        return workspaces[workspaceID]
    }
    
    public var currentWorkspaceMember: MemberData? { currentWorkspace?.userMemberInfo }
    
    // MARK: - Members
    /// A dictionary that stores all workspaces' members.
    @Published public var workspacesMembers: [String : Loadable<AnyStreamable<MemberData>>] = [:]
    /// A dictionary that only stores all private groups' members.
    @Published public var privateGroupsMembers: [String : [String]] = [:]
    
    public var currentWorkspaceMembers: Loadable<AnyStreamable<MemberData>> {
        guard let currentWorkspaceID = currentWorkspaceID else { return .notRequested }
        return workspacesMembers[currentWorkspaceID] ?? .notRequested
    }
    /// A dictionary describes all members.
    public var members: [MemberData.ID : MemberData] {
        workspacesMembers.values.map {
            $0.map { formDic(payload: $0.items, id: \.memberID) }.value ?? [:]
        }
        .merged()
    }
    
    
    // MARK: - Groups
    
    /// A dictionary that stores all workspaces' groups.
    @Published public var workspacesGroups: [String : Loadable<WorkspaceGroupsData>] = [:] {
        didSet {
            workspacesGroups.forEach { (workspaceID, groups) in
                ((groups.value?.team ?? []) + (groups.value?.team ?? [])).forEach { group in
                    // viewsInfo
                    group.viewInfo.forEach { viewInfo in
                        if viewsTrickles[viewInfo.id] == nil {
                            resetViewTrickles(viewInfo.id)
                        }
                    }
                }
            }

        }
    }
    @Published public var workspacesMemoryGroups: [WorkspaceData.ID : Loadable<WorkspaceMemoryGroupsData>] = [:]
    
    public var currentWorkspaceGroups: Loadable<WorkspaceGroupsData>? {
        guard let currentWorkspace = currentWorkspace else { return nil }
        return workspacesGroups[currentWorkspace.workspaceID] ?? .notRequested
    }
    
    public var groups: [GroupData.ID : GroupData] {
        workspacesGroups.values
            .map {
                $0.map { formDic(payload: $0.personal + $0.team, id: \.groupID) }.value ?? [:]
            }
            .merged()
    }
    
    @AppStorage("lastWorkspacesGroupID") public var lastWorkspacesGroupID: [WorkspaceData.ID : GroupData.ID] = [:]
    @Published public var currentGroupID: GroupData.ID? = nil {
        didSet {
            if let currentGroupID = currentGroupID,
               let currentWorkspace = currentWorkspace {
                lastWorkspacesGroupID[currentWorkspace.workspaceID] = currentGroupID
                Task {
                    await ackGroup(groupID: currentGroupID)
                }
            }
        }
    }
    
    public var currentGroup: GroupData? {
        guard let groupID = currentGroupID else { return nil }
        return groups[groupID]
    }
    
    // MARK: - View Info
    
    /// A dictionary describes all trickles of `groupView`s.
    /// The value of dictionary store all trickles group by field value's id.
    @Published public var viewsTrickleIDs: [GroupData.ViewInfo.ID : [FieldOptions.FieldOptionInfo.ID : Loadable<AnyQueryStreamable<TrickleData.ID>>]] = [:]
    public var viewsTrickles: [GroupData.ViewInfo.ID : [FieldOptions.FieldOptionInfo.ID : Loadable<AnyQueryStreamable<TrickleData>>]] {
        viewsTrickleIDs.map {
            [$0.key : $0.value.map {
                [$0.key : $0.value.map { .init(items: $0.items.compactMap {trickles[$0]}, nextQuery: $0.nextQuery) } ]
            }.merged() ]
        }.merged()
    }
    
    @AppStorage("lastGroupsViewID") public var lastGroupsViewID: [GroupData.ViewInfo.ID : GroupData.ViewInfo.ID] = [:]
    
    public var views: [GroupData.ViewInfo.ID : GroupData.ViewInfo] {
        groups.values.flatMap { $0.viewInfo.map { [$0.viewID : $0] } }.merged()
    }
    
    @Published public var currentGroupViewID: GroupData.ViewInfo.ID? = nil {
        didSet {
            if let currentGroupViewID = currentGroupViewID,
               let currentGroup = currentGroup {
                lastGroupsViewID[currentGroup.groupID] = currentGroupViewID
            }
        }
    }
    public var currentGroupView: GroupData.ViewInfo? {
        guard let currentGroupViewID = currentGroupViewID else { return nil }
        return views[currentGroupViewID]
    }
    
    //MARK: - Stat / FieldOptions
    @Published public var viewsTricklesStat: [GroupData.ViewInfo.ID : Loadable<GroupViewTricklesStat>] = [:]

    public var currentViewTricklesStat: Loadable<GroupViewTricklesStat>? {
        guard let currentGroup = currentGroup else { return nil }
        return viewsTricklesStat[currentGroup.groupID] ?? .notRequested
    }
    
    /// This is a dictionary represents `FieldsOptions` of every group.
    ///
    /// `FieldsOptions` are the table cell dropdown options of database view.
    @Published public var groupsFieldsOptions: [GroupData.ID : Loadable<FieldsOptions>] = [:]
    
    // MARK: - Trickles/Threads/Notifications/Stars
    /// A dictionary that stores all groups' trickles.
    @Published public var trickles: [String : TrickleData] = [:]
    @available(*, deprecated)
    @Published internal var groupsTrickleIDs: [String : Loadable<AnyQueryStreamable<TrickleData.ID>>] = [:]
    @Published internal var workspaceThreadIDs: [WorkspaceData.ID : Loadable<AnyStreamable<TrickleData.ID>>] = [:]
    
    @Published public var workspacesThreadsUnreadCount: [WorkspaceData.ID : Int] = [:]
    @available(*, deprecated)
    public var groupsTrickles: [GroupData.ID : [TrickleData]] {
        var result: [GroupData.ID : [TrickleData]] = [:]
        // group all view's trickles
        result = groups.map { (groupID, group) in
            [
                groupID :
                    group.viewInfo.flatMap { viewInfo in
                        viewsTrickles[viewInfo.viewID]?.values.flatMap({$0.value?.items ?? []}) ?? []
                    }
                    .removingDuplicate()
            ]
        }.merged()
        return result
    }
    
    public var workspaceThreads: [WorkspaceData.ID : Loadable<AnyStreamable<TrickleData>>] {
        var result: [WorkspaceData.ID : Loadable<AnyStreamable<TrickleData>>] = [:]
        workspaceThreadIDs.forEach { key, loadable in
            result[key] = loadable.map {
                .init(items: $0.items.compactMap { trickles[$0] },
                      nextTs: $0.nextTs)
            }
        }
        return result
    }
    @available(*, deprecated)
    public var currentGroupTrickles: [TrickleData] {
        guard let currentGroupID = currentGroupID else { return [] }
        return groupsTrickles[currentGroupID] ?? []
    }
//    public var currentViewTrickles: Loadable<[FieldOptions.FieldOptionInfo.ID : Loadable<AnyQueryStreamable<TrickleData>>]>? {
//        guard let currentGroupViewID = currentGroupViewID else { return nil }
//        return viewsTrickles[currentGroupViewID] ?? .notRequested
//    }
    @available(*, deprecated)
    public var currentWorkspaceThreads: Loadable<AnyStreamable<TrickleData>> {
        guard let currentWorkspaceID = currentWorkspaceID else { return .notRequested }
        return workspaceThreads[currentWorkspaceID] ?? .notRequested
    }
    
    @Published public var currentTrickleID: String? = nil
    public var currentTrickle: TrickleData? {
        guard let currentTrickleID = currentTrickleID else { return nil }
        return trickles[currentTrickleID]
    }
    
    @Published public var workspacesDirectMessageIDs: [WorkspaceData.ID : Loadable<AnyStreamable<TrickleData.ID>>] = [:]
    public var workspacesDirectMessages: [WorkspaceData.ID : Loadable<AnyStreamable<TrickleData>>] {
        workspacesDirectMessageIDs.map {
            [$0.key : $0.value.map{ $0.compactMap{ trickles[$0] } }]
        }.merged()
    }
    @Published public var workspacesDirectMessagesUnreadCount: [WorkspaceData.ID : Int] = [:]

    @Published public var workspacesTrickleIDs: [WorkspaceData.ID : Loadable<AnyStreamable<TrickleData.ID>>] = [:]
    public var workspacesTrickles: [WorkspaceData.ID : Loadable<AnyStreamable<TrickleData>>] {
        workspacesTrickleIDs.map {
            [$0.key : $0.value.map { $0.compactMap{ trickles[$0] } }]
        }
        .merged()
    }
    
    
    // MARK: - Trickles Comments
    @Published public var tricklesCommentIDs: [TrickleData.ID : Loadable<AnyStreamable<CommentData.ID>>] = [:]
    public var tricklesComments: [TrickleData.ID : Loadable<AnyStreamable<CommentData>>] {
        tricklesCommentIDs.map { (key, value) in
            [key: value.map{ $0.compactMap{ comments[$0] } }]
        }.merged()
    }
    @Published public var comments: [CommentData.ID : CommentData] = [:]
    public var currentTrickleComments: Loadable<AnyStreamable<CommentData>> {
        guard let currentTrickleID = currentTrickleID else { return .notRequested }
        return tricklesCommentIDs[currentTrickleID]?.map{ .init(items: $0.items.compactMap{comments[$0]}, nextTs: $0.nextTs) } ?? .notRequested
    }
    
    
    // MARK: - Pins
    @Published public var groupsPinTrickleIDs: [GroupData.ID : [TrickleData.ID]] = [:]
    public var groupsPinTrickles: [GroupData.ID : [TrickleData]] {
        groupsPinTrickleIDs.map {
            [$0.key : $0.value.compactMap{trickles[$0]}]
        }.merged()
    }
    @available(*, deprecated)
    public var currentGroupPinTrickles: [TrickleData] {
        guard let currentGroupID = currentGroupID else { return [] }
        return groupsPinTrickles[currentGroupID] ?? []
    }
    
    // MARK: - Stars
    @Published public var starredTrickleIDs: [WorkspaceData.ID : Loadable<AnyStreamable<TrickleData.ID>>] = [:]
    
    
    // MARK: - AIAgent
    @Published public var aiAgentState: AIAgentState = .init() // can not trigger view update when changed if it is ObservableObject
//    @Published public var aiAgents: [AIAgentData] = []
    
    
    // MARK: - Error
    @Published public var error: TrickleStoreError? = nil {
        didSet {
            if let error = error {
                historyErrors.append(error)
            }
        }
    }
    @Published public var historyErrors: [TrickleStoreError] = []
    
    // MARK: - Actions
    
    public func reinit() {
        print("reinit")
        userInfo = .notRequested
        allWorkspaces = .notRequested
        currentWorkspaceID = nil
        workspacesMembers.removeAll()
        privateGroupsMembers.removeAll()
        workspacesGroups.removeAll()
        viewsTrickleIDs.removeAll()
        lastGroupsViewID.removeAll()
        currentGroupID = nil
        viewsTricklesStat.removeAll()
        groupsFieldsOptions.removeAll()
        trickles.removeAll()
        workspaceThreadIDs.removeAll()
        workspacesThreadsUnreadCount.removeAll()
        workspacesDirectMessageIDs.removeAll()
        workspacesDirectMessagesUnreadCount.removeAll()
        currentTrickleID = nil
        tricklesCommentIDs.removeAll()
        comments.removeAll()
        error = nil
        historyErrors.removeAll()
        
        socket.reinitSocket()
    }
    
    public enum LoadMoreOption {
        case older(_ since: Date? = nil)
        case newer(_ since: Date? = nil)
        case refresh
    }
}
