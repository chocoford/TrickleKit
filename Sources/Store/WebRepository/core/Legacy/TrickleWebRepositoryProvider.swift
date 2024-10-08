//
//  TrickleWebRepositoryProvider.swift
//  
//
//  Created by Chocoford on 2023/3/17.
//
import Foundation
import WebProvider
import Combine
import OSLog
import TrickleCore

protocol TrickleWebRepositoryProvider {
    // MARK: - Auth
    /// Get userdata of  current logined user.
    func getUserData(userID: String) -> AnyPublisher<UserInfo?, Error>
    func loginViaPassword(payload: TrickleWebRepository.API.PasswordLoginPayload) async throws -> AuthData
    func sendCode(payload: TrickleWebRepository.API.SendCodePayload) async throws -> String
    func signup(payload: TrickleWebRepository.API.SignupPayload) async throws -> String
    
    func updateUserData(userID: UserInfo.UserData.ID, payload: TrickleWebRepository.API.UpdateUserDataPayload) async throws -> String
//    func updateUserAvatar(userID: UserInfo.UserData.ID, avatarURL: String) async throws -> String
//    func updateUserNickname(userID: UserInfo.UserData.ID, nickname: String) async throws -> String
    
    // MARK: - Connections
    func getSupportedConnections() async throws -> AnyStreamable<Connection>
    
    // MARK: - Workspace
    func listUserWorkspaces(userID: String) ->  AnyPublisher<AnyStreamable<WorkspaceData>, Error>
    func getWorkspaceInvitations(workspaceID: WorkspaceData.ID) async throws -> [WorkspaceInvitationData]
    func createWorkspaceInvitation(workspaceID: WorkspaceData.ID, payload: TrickleWebRepository.API.CreateWorkspaceInvitationPayload) async throws -> TrickleWebRepository.API.CreateWorkspaceInvitationResponseData

    func createWorkspace(payload: TrickleWebRepository.API.CreateWorkspacePayload) async throws -> TrickleWebRepository.API.CreateWorkspaceResponseData
    func updateWorkspace(workspaceID: WorkspaceData.ID, payload: TrickleWebRepository.API.UpdateWorkspacePayload) async throws -> TrickleWebRepository.API.UpdateWorkspaceResponseData
    func leaveWorkspace(workspaceID: WorkspaceData.ID, payload: TrickleWebRepository.API.MemberOnlyPayload) async throws -> String
    func sendWorkspaceInvitations(workspaceID: String, invitationID: String, payload: TrickleWebRepository.API.SendEmailPayload) async throws -> String
    
    // MARK: - Members
    func listWorkspaceMembers(workspaceID: String, limit: Int) ->  AnyPublisher<AnyStreamable<MemberData>, Error>
    func listGroupMembers(workspaceID: String, groupID: String) ->  AnyPublisher<AnyStreamable<MemberData>, Error>
    
    // MARK: - Groups
    func listWorkspaceGroups(workspaceID: WorkspaceData.ID, memberID: MemberData.ID) ->  AnyPublisher<WorkspaceGroupsData, Error>
    func listWorkspaceGroups(workspaceID: WorkspaceData.ID, memberID: MemberData.ID) async throws -> WorkspaceGroupsData
    func listWorkspaceMemoryGroups(workspaceID: WorkspaceData.ID, memberID: MemberData.ID) async throws -> WorkspaceMemoryGroupsData
    
    func createGroup(workspaceID: WorkspaceData.ID, payload: TrickleWebRepository.API.CreateGroupPayload) async throws -> GroupData
    func createPersonalGroup(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, payload: TrickleWebRepository.API.CreateGroupPayload) async throws -> GroupData
    func updateGroup(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, payload: TrickleWebRepository.API.UpdateGroupPayload) async throws -> GroupData
    func deleteGroup(workspaceID: WorkspaceData.ID, groupID: GroupData.ID) async throws -> String
    
    func ackGroup(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, payload: TrickleWebRepository.API.AckGroupPayload) async throws -> String
    
    
    // MARK: - Views
    func listGroupViewTricklesStat(workspaceID: String, groupID: String, query: TrickleWebRepository.API.ListGroupViewTricklesStatQuery) async throws -> GroupViewTricklesStat
    
    // MARK: - Posts
    func createPost(workspaceID: WorkspaceData.ID,
                    groupID: GroupData.ID,
                    payload: TrickleWebRepository.API.CreatePostPayload) async throws -> TrickleData
    
    func listTrickles(workspaceID: WorkspaceData.ID, query: TrickleWebRepository.API.ListTricklesQuery) async throws -> AnyStreamable<TrickleData>
    func listGroupTrickles(workspaceID: String, groupID: String,
                           query: NextQuery) -> AnyPublisher<AnyQueryStreamable<TrickleData>, Error>
    
    func listFieldOptions(workspaceID: String, groupID: String) -> AnyPublisher<FieldsOptions, Error>
    
    func copyTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: TrickleWebRepository.API.CopyTricklePayload) async throws -> TrickleWebRepository.API.CopyTrickleResponse
    func addTrickleLastView(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: TrickleWebRepository.API.AddTrickleLastViewPayload) async throws -> String
    
    // MARK: - Comments
    func createTrickleComments(workspaceID: String, trickleID: String, payload: TrickleWebRepository.API.CreateCommentPayload) async throws -> TrickleWebRepository.API.CreateCommentResponseData
    func listTrickleComments(workspaceID: String, trickleID: String, query: TrickleWebRepository.API.ListQuery) async throws -> AnyStreamable<CommentData>
    func ackTrickleComments(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: TrickleWebRepository.API.ACKTrickleCommentsPayload) async throws -> String
    
    // MARK: - Threads
    func listWorkspaceThreads(workspaceID: String, memberID: String, query: TrickleWebRepository.API.ListQuery) -> AnyPublisher<AnyStreamable<TrickleData>, Error>
    func getWorkspaceThreadsUnreadCount(workspaceID: String, memberID: String) async throws -> TrickleWebRepository.API.ThreadsUnreadCountResponse
    
    // MARK: - DirectMessage
    func createWorkspaceDirectMessage(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, payload: TrickleWebRepository.API.CreateDirectMessagePayload) async throws -> TrickleData
    func listWorkspaceDirectMessages(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, query: TrickleWebRepository.API.ListQuery) async throws -> AnyStreamable<TrickleData>
    func getWorkspaceDirectMessagesUnreadCount(workspaceID: WorkspaceData.ID, memberID: MemberData.ID) async throws -> TrickleWebRepository.API.DirectMessagesUnreadCountResponse
    
    // MARK: - Reactions
    func createTrickleReaction(workspaceID: String, trickleID: String, payload: TrickleWebRepository.API.CreateReactionPayload) async throws -> ReactionData
    func deleteTrickleReaction(workspaceID: String, trickleID: String, reactionID: String, payload: TrickleWebRepository.API.MemberOnlyPayload) async throws -> String
    
    // MARK: - Pins
    func pinTrickle(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, trickleID: TrickleData.ID, payload: TrickleWebRepository.API.PinTricklePayload) async throws -> String
    func unpinTrickle(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, trickleID: TrickleData.ID) async throws -> String
    func listPinTrickles(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, query: TrickleWebRepository.API.ListPinTrickleQuery) async throws -> AnyStreamable<TrickleData>
    
    // MARK: - Stars
    func starTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: TrickleWebRepository.API.StarTricklePayload) async throws -> String
    func unstarTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: TrickleWebRepository.API.UnstarTricklePayload) async throws -> String
    
    // MARK: - Subscription
    func createPaymentLink(workspaceID: WorkspaceData.ID, payload: TrickleWebRepository.API.CreatePaymentLinkPayload) async throws -> PaymentLinkData
    func createStripePortalSession(workspaceID: WorkspaceData.ID) async throws -> PaymentLinkData
    func getSubscriptionPlans(workspaceID: WorkspaceData.ID) async throws -> AnyStreamable<SubscriptionPlanData>
    func getSubscriptionStatus(workspaceID: WorkspaceData.ID) async throws -> SubscriptionStatusData?
    func getSubscriptionUpcomingInvoices(workspaceID: WorkspaceData.ID, query: TrickleWebRepository.API.GetSubscriptionUpcomingInvoicesQuery) async throws -> SubscriptionUpcomingInvoicesData
}
