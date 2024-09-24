//
//  TrickleAPI.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Foundation
import WebProvider
import TrickleCore


extension TrickleWebRepository {
    enum API {
        // users
        case getUserData(userID: String)
        case loginViaPassword(paylaod: PasswordLoginPayload)
        case sendCode(payload: SendCodePayload)
        case updateUserData(userID: UserInfo.UserData.ID, payload: UpdateUserDataPayload)
        case signup(paylaod: SignupPayload)
        
        // connections
        case getSupportedConnections
        
        // workspaces
        case listWorkspaces(userID: String)
        case getWorkspaceInvitations(workspaceID: WorkspaceData.ID)
        case createWorkspaceInvitation(workspaceID: WorkspaceData.ID, payload: CreateWorkspaceInvitationPayload)
        case createWorkspace(payload: CreateWorkspacePayload)
        case updateWorkspace(workspaceID: WorkspaceData.ID, payload: UpdateWorkspacePayload)
        case leaveWorkspace(workspaceID: WorkspaceData.ID, payload: MemberOnlyPayload)
        case sendWorkspaceInvitations(workspaceID: WorkspaceData.ID, invitationID: String, payload: SendEmailPayload)
        
        // members
        case listWorkspaceMembers(workspaceID: WorkspaceData.ID, limit: Int)
        case listGroupMembers(workspaceID: WorkspaceData.ID, groupID: String)
        
        // groups
        case createGroup(workspaceID: WorkspaceData.ID, payload: CreateGroupPayload)
        case createPersonalGroup(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, payload: CreateGroupPayload)
        case listWorkspaceGroups(workspaceID: WorkspaceData.ID, memberID: String)
        case listWorkspaceMemoryGroups(workspaceID: WorkspaceData.ID, memberID: MemberData.ID)
        case updateGroup(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, payload: UpdateGroupPayload)
        case deleteGroup(workspaceID: WorkspaceData.ID, groupID: GroupData.ID)
        case ackGroup(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, payload: AckGroupPayload)
        // views
        case listGroupViewTricklesStat(workspaceID: WorkspaceData.ID, groupID: String, query: API.ListGroupViewTricklesStatQuery)
        
        // fileds
        case listFieldOptions(workspaceID: WorkspaceData.ID, groupID: String)
        
        // trickles
        case createPost(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, payload: CreatePostPayload)
        case listTrickles(workspaceID: WorkspaceData.ID, query: ListTricklesQuery)
        case listGroupTrickles(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, payload: NextQuery)
        case copyTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: CopyTricklePayload)
        case addTrickleLastView(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: AddTrickleLastViewPayload)

        // comments
        case createTrickleComment(workspaceID: WorkspaceData.ID, trickleID: String, payload: CreateCommentPayload)
        case listTrickleComments(workspaceID: WorkspaceData.ID, trickleID: String, query: ListQuery)
        case ackTrickleComments(workspaceID: WorkspaceData.ID, trickleID: String, payload: ACKTrickleCommentsPayload)
        
        // directMessage
        case createWorkspaceDirectMessage(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, payload: CreateDirectMessagePayload)
        case listWorkspaceDirectMessages(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, query: ListQuery)
        case getWorkspaceDirectMessagesUnreadCount(workspaceID: WorkspaceData.ID, memberID: MemberData.ID)
        
        // reactions
        case createTrickleReaction(workspaceID: WorkspaceData.ID, trickleID: String, payload: CreateReactionPayload)
        case deleteTrickleReaction(workspaceID: WorkspaceData.ID, trickleID: String, reactionID: String, payload: MemberOnlyPayload)
        
        // pins
        case pinTrickle(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, trickleID: TrickleData.ID, payload: PinTricklePayload)
        case unpinTrickle(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, trickleID: TrickleData.ID)
        case listPinTrickles(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, query: ListPinTrickleQuery)
        
        // stars
        case starTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: StarTricklePayload)
        case unstarTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: UnstarTricklePayload)
        
        // threads
        case listWorkspaceThreads(workspaceID: WorkspaceData.ID, memberID: String, query: ListQuery)
        case getWorkspaceThreadsUnreadCount(workspaceID: WorkspaceData.ID, memberID: String)
        
        // subscription
        case createPaymentLink(workspaceID: WorkspaceData.ID, payload: CreatePaymentLinkPayload)
        case createStripePortalSession(workspaceID: WorkspaceData.ID)
        case getSubscriptionPlans(workspaceID: WorkspaceData.ID)
        case getSubscriptionStatus(workspaceID: WorkspaceData.ID)
        case getSubscriptionUpcomingInvoices(workspaceID: WorkspaceData.ID, query: GetSubscriptionUpcomingInvoicesQuery)
    }
}

extension TrickleWebRepository.API: APICall {
    var path: String {
        switch self {
            case .getUserData(let userID):
                return "/auth/user/\(userID)"
            case .loginViaPassword:
                return "/auth/token"
            case .sendCode:
                return "/auth/sendcode"
            case .updateUserData(let userID, _):
                return "/auth/user/\(userID)"
            case .signup:
                return "/auth/signup"
                
            // workspace
            case .listWorkspaces:
                return "/f2b/v1/workspaces"

            case .getWorkspaceInvitations(let workspaceID):
                return "/f2b/v1/workspace/\(workspaceID)/workspaceInvitations"
            case .createWorkspaceInvitation(let workspaceID, _):
                return "/f2b/v1/workspace/\(workspaceID)/workspaceInvitations"
                
                
            case .createWorkspace:
                return "/f2b/v1/workspaces"
            case .updateWorkspace(let workspaceID, _):
                return "/f2b/v1/workspaces/\(workspaceID)"
            case .leaveWorkspace(let workspaceID, _):
                return "/f2b/v1/workspaces/\(workspaceID):leave"
            case .sendWorkspaceInvitations(let workspaceID, let invitationID, _):
                return "/f2b/v1/workspace/\(workspaceID)/workspaceInvitations/\(invitationID):send"
                
            case .getSupportedConnections:
                return "f2b/v1/connection/supportedConnections"
                
            // members
            case .listWorkspaceMembers(let workspaceID, let limit):
                return "/f2b/v1/workspaces/\(workspaceID)/members?limit=\(limit)"

            case .listGroupMembers(let workspaceID, let groupID):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)/members?limit=1024"

            // groups
            case let .createGroup(workspaceID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/groups"
            case .createPersonalGroup(let workspaceID, let memberID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/members/\(memberID)/channels"
            case .listWorkspaceGroups(let workspaceID, let memberID):
                return "/f2b/v1/workspaces/\(workspaceID)/myChannels?memberId=\(memberID)"
            case .listWorkspaceMemoryGroups(let workspaceID, _):
                return "/trickle/workspaces/\(workspaceID)/memoryChannels"
                
            case .listGroupViewTricklesStat(let workspaceID, let groupID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)/trickles/stats"
            case .updateGroup(let workspaceID, let groupID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)"
            case .deleteGroup(let workspaceID, let groupID):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)"
            case .ackGroup(let workspaceID, let groupID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID):ack"
                
            // Fields
            case .listFieldOptions(let workspaceID, let groupID):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)/fields/-/fieldOptions"
                
            // Post CRUD API
            case .createPost(let workspaceID, let groupID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)/trickles"
                
            case let .listTrickles(workspaceID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles"
                
            case .listGroupTrickles(let workspaceID, let groupID, _):
                return  "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)/trickles"
                
            case .copyTrickle(let workspaceID, let trickleID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles/\(trickleID):copy"
                
            case .addTrickleLastView(let workspaceID, let trickleID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles/\(trickleID)/lastViewedMembers"
                
            // Comments
            case .createTrickleComment(let workspaceID, let trickleID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles/\(trickleID)/comments"
            case .listTrickleComments(let workspaceID, let trickleID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles/\(trickleID)/messages"
            case .ackTrickleComments(let workspaceID, let trickleID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles/\(trickleID)/comments:ack"
                
            // Direct Messages
            case .createWorkspaceDirectMessage(let workspaceID, let memberID, _):
                return "/trickle/workspaces/\(workspaceID)/members/\(memberID)/dmTrickles"
            case .listWorkspaceDirectMessages(let workspaceID, let memberID, _):
                return "/trickle/workspaces/\(workspaceID)/members/\(memberID)/dmTrickles"
            case .getWorkspaceDirectMessagesUnreadCount(let workspaceID, let memberID):
                return "/trickle/workspaces/\(workspaceID)/members/\(memberID)/dmUnreadCount"
                
            // Reactions
            case .createTrickleReaction(let workspaceID, let trickleID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles/\(trickleID)/reactions"
            case .deleteTrickleReaction(let workspaceID, let trickleID, let reactionID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles/\(trickleID)/reactions/\(reactionID)"
                
            // Pin
            case .pinTrickle(let workspaceID, let groupID, let trickleID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)/pins/\(trickleID)"
            case .unpinTrickle(let workspaceID, let groupID, let trickleID):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)/pins/\(trickleID)"
            case .listPinTrickles(let workspaceID, let groupID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/groups/\(groupID)/pins"
                
            // Stars
            case .starTrickle(let workspaceID, let trickleID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles/\(trickleID):star"
            case .unstarTrickle(let workspaceID, let trickleID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/trickles/\(trickleID):unstar"
                
            // Threads
            case .listWorkspaceThreads(let workspaceID, let memberID, _):
                return "/f2b/v1/workspaces/\(workspaceID)/members/\(memberID)/workspaceThreads"
            case .getWorkspaceThreadsUnreadCount(let workspaceID, let memberID):
                return "/f2b/v1/workspaces/\(workspaceID)/members/\(memberID)/threadsUnreadCount"
                
            // Subscription
            case .createPaymentLink(let workspaceID, _):
                return "/subs/v1/workspaces/\(workspaceID)/paymentLinks"
            case .createStripePortalSession(let workspaceID):
                return "/subs/v1/workspaces/\(workspaceID)/stripe/portalSession"
            case .getSubscriptionPlans:
                return "/subs/v1/plans/available"
            case .getSubscriptionStatus(let workspaceID):
                return "/subs/v1/workspaces/\(workspaceID)/subscriptions/active"
            case .getSubscriptionUpcomingInvoices(let workspaceID, _):
                return "/subs/v1/workspaces/\(workspaceID)/invoices/upcoming"
        }
    }
    
    var gloabalQueryItems: Encodable? {
        struct TrickleWebAPIQuery: Codable {
            var version: Int = Int(Date().timeIntervalSince1970 * 1000)
            var apiVersion: Int = 2
        }
        return TrickleWebAPIQuery()
    }

    var queryItems: Encodable? {
        switch self {
            case .listWorkspaces(let userID):
                struct Query: Codable {
                    var userId: String
                }
                return Query(userId: userID)
            case .listWorkspaceMemoryGroups(_, let memberID):
                return MemberOnlyQuery(memberID: memberID)
            case .listTrickles(_, let payload):
                return payload
            case .listGroupTrickles(_, _, let payload):
                do {
                    return try SortStringifyPayload(memberID: payload.memberID,
                                                    limit: payload.limit,
                                                    sorts: payload.sorts.jsonStringified(),
                                                    groupByFilters: payload.groupByFilters.jsonStringified())
                } catch {
                    dump(error)
                    break
                }
                
            case .listTrickleComments(_, _, let query):
                return query
                
            case .listWorkspaceThreads(_, _, let query):
                return query
                
            case .listGroupViewTricklesStat(_, _, let query):
                do {
                    return try ListGroupViewTricklesStatStringifiedQuery(groupBy: query.groupBy.jsonStringified(),
                                                                         filterLogicalOperator: query.filterLogicalOperator,
                                                                         filters: query.filters.jsonStringified())
                } catch {
                    dump(error)
                    break
                }
            case .listPinTrickles(_, _, let query):
                return query
                
            case .listWorkspaceDirectMessages(_, _, let query):
                return query
                
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
        return nil
    }
    
    var method: APIMethod {
        switch self {
            case .loginViaPassword,
                    .sendCode,
                    .signup,
                    .createWorkspace,
                    .updateWorkspace,
                    .leaveWorkspace,
                    .createWorkspaceInvitation,
                    .sendWorkspaceInvitations,
                    .createGroup,
                    .ackGroup,
                    .createPost,
                    .addTrickleLastView,
                    .createTrickleComment,
                    .createWorkspaceDirectMessage,
                    .ackTrickleComments,
                    .createTrickleReaction,
                    .pinTrickle,
                    .starTrickle,
                    .unstarTrickle,
                    .copyTrickle,
                    .createPaymentLink,
                    .createStripePortalSession:
                return .post
                
            case .deleteGroup, .deleteTrickleReaction, .unpinTrickle:
                return .delete
                
            case .updateUserData, .updateGroup:
                return .patch
                
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
            case .loginViaPassword(let payload):
                defaults["Authorization"] = "Basic MTc4ODE3MDEzMzQxMjI1MDg6aHkxWFRIeEJLNkdQSFNUWnYxODZYaEZudk5UdXRB"
                defaults["Content-Type"] = "multipart/form-data; boundary=\(payload.boundary)"
                defaults["Content-Length"] = "\(payload.data.count)"
                
            case .signup(let paylaod):
                switch paylaod {
                    case .validate(let payload):
                        defaults["Content-Type"] = "multipart/form-data; boundary=\(payload.boundary)"
                        defaults["Content-Length"] = "\(payload.data.count)"
                        
                    case .actualSignup(let payload):
                        defaults["Content-Type"] = "multipart/form-data; boundary=\(payload.boundary)"
                        defaults["Content-Length"] = "\(payload.data.count)"
                }
                
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
    
    var rateLimit: APICallRateLimit? { nil }

    func body() throws -> Data? {
        switch self {
            case .loginViaPassword(let payload):
                return payload.data
            case .sendCode(let payload):
                return try makeBody(payload: payload)
            case .signup(let payload):
                switch payload {
                    case .actualSignup(let p):
                        return p.data
                    case .validate(let p):
                        return p.data
                }
            case .updateUserData(_, let payload):
                return try makeBody(payload: payload)
            case .createWorkspace(let payload):
                return try makeBody(payload: payload)
            case .updateWorkspace(_, let payload):
                return try makeBody(payload: payload)
            case .leaveWorkspace(_, let payload):
                return try makeBody(payload: payload)
            case .createWorkspaceInvitation(_ , let payload):
                return try makeBody(payload: payload)
            case .sendWorkspaceInvitations(_, _, let payload):
                return try makeBody(payload: payload)
            case let .createGroup(_, payload):
                return try makeBody(payload: payload)
            case .updateGroup(_, _, let payload):
                return try makeBody(payload: payload)
            case .ackGroup(_, _, let payload):
                return try makeBody(payload: payload)
            case .createPost(_, _, let payload):
                return try makeBody(payload: payload)
            case .addTrickleLastView(_, _, let payload):
                return try makeBody(payload: payload)
            case .createTrickleComment(_, _, let payload):
                return try makeBody(payload: payload)
            case .createWorkspaceDirectMessage(_, _, let payload):
                return try makeBody(payload: payload)
            case .ackTrickleComments(_, _, let payload):
                return try makeBody(payload: payload)
            case .createTrickleReaction(_, _, let payload):
                return try makeBody(payload: payload)
            case .deleteTrickleReaction(_, _, _, let payload):
                return try makeBody(payload: payload)
            case .pinTrickle(_, _, _, let payload):
                return try makeBody(payload: payload)
            case .starTrickle(_, _, let payload):
                return try makeBody(payload: payload)
            case .unstarTrickle(_, _, let payload):
                return try makeBody(payload: payload)
            case .copyTrickle(_, _, let payload):
                return try makeBody(payload: payload)
            case .createPaymentLink(_, let payload):
                return try makeBody(payload: payload)
            default:
                return nil
        }
        
    }
}


