//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

public extension TrickleStore {
    func loadMoreComments(_ trickleID: TrickleData.ID, option: LoadMoreOption, silent: Bool = false) async {
        guard let theTrickle = trickles[trickleID] else { return }
        
        if !silent {
            tricklesCommentIDs[trickleID]?.setIsLoading()
        }
        
        let nextTS: TrickleWebRepository.API.ListQuery
        switch option {
            case .newer(let since):
                nextTS = .init(until: Int((since ?? tricklesComments[trickleID]?.value?.items.first?.updateAt ?? .now).timeIntervalSince1970),
                               limit: 1000,
                               order: .asc)
            case .older:
                nextTS = .init(until: tricklesCommentIDs[trickleID]?.value?.nextTs ?? Int(Date.now.timeIntervalSince1970),
                              limit: 20,
                              order: .desc)
        }
        
        do {
            let theWorkspace = try findGroupWorkspace(theTrickle.groupInfo.groupID)
            let data = try await webRepositoryClient.listTrickleComments(workspaceID: theWorkspace.workspaceID,
                                                                         trickleID: trickleID,
                                                                         query: nextTS)
            switch option {
                case .newer:
                    prependComments(to: trickleID, commentsData: data)
                case .older:
                    appendComments(to: trickleID, commentsData: data)
            }
        } catch {
            if !silent {
                self.error = .init(error)
                tricklesCommentIDs[trickleID]?.setAsFailed(error)
            }
        }
    }
    
    func tryCreateComment(_ trickleID: TrickleData.ID, blocks: [TrickleData.Block], mentionedMemberIDs: [MemberData.ID], quoteCommentID: CommentData.ID?) async throws {
        let workspace = try findTrickleWorkspace(trickleID)
        
        let fakeComment = CommentData(commentID: UUID().uuidString,
                                      typ: .normal,
                                      text: nil,
                                      blocks: blocks,
                                      hasQuoted: quoteCommentID != nil,
                                      commentAuthor: workspace.userMemberInfo,
                                      mentionedMemberInfo: workspacesMembers[workspace.workspaceID]?.value?.items ?? [],
                                      quoteCommentInfo: quoteCommentID == nil ? nil : comments[quoteCommentID!]?.quoted,
                                      reactionInfo: [],
                                      createAt: .now,
                                      updateAt: .now)
        addComment(to: trickleID, commentData: fakeComment)
        
        let oldUpdateAt = trickles[trickleID]?.updateAt
        trickles[trickleID]?.updateAt = .now
        reorderThreads(workspace.workspaceID)
        do {
            let data = try await webRepositoryClient.createTrickleComments(workspaceID: workspace.workspaceID,
                                                                           trickleID: trickleID,
                                                                           payload: .init(authorMemberID: workspace.userMemberInfo.memberID,
                                                                                          mentionedMemberIDs: mentionedMemberIDs,
                                                                                          blocks: blocks,
                                                                                          quoteCommentID: quoteCommentID))
            
            let commentData = data.comment
            updateComment(from: fakeComment, to: commentData, of: trickleID)
        } catch {
            removeComment(fakeComment.commentID, of: trickleID)
            trickles[trickleID]?.updateAt = oldUpdateAt
            throw error
        }
    }
    
    func createComment(_ trickleID: TrickleData.ID, blocks: [TrickleData.Block], mentionedMemberIDs: [MemberData.ID], quoteCommentID: CommentData.ID?) async {
        do {
            try await tryCreateComment(trickleID, blocks: blocks, mentionedMemberIDs: mentionedMemberIDs, quoteCommentID: quoteCommentID)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryAckComments(_ trickleID: TrickleData.ID) async throws {
        guard let trickle = trickles[trickleID], let comments = tricklesComments[trickleID]?.value?.items else {
            throw TrickleStoreError.invalidTrickleID(trickleID)
        }
        let originaLastViewInfo = trickle.lastViewInfo
        
        trickles[trickleID]?.lastViewInfo.unreadCount = 0
        trickles[trickleID]?.lastViewInfo.lastACKMessageCreateAt = comments.first?.createAt
        trickles[trickleID]?.lastViewInfo.lastACKMessageID = comments.first?.commentID
        
        let workspace = try findTrickleWorkspace(trickleID)
        do {
            _ = try await webRepositoryClient.ackTrickleComments(workspaceID: workspace.workspaceID,
                                                                 trickleID: trickleID,
                                                                 payload: .init(memberID: workspace.userMemberInfo.memberID))
        } catch {
            trickles[trickleID]?.lastViewInfo.unreadCount = originaLastViewInfo.unreadCount
            trickles[trickleID]?.lastViewInfo.lastACKMessageCreateAt = originaLastViewInfo.lastACKMessageCreateAt
            trickles[trickleID]?.lastViewInfo.lastACKMessageID = originaLastViewInfo.lastACKMessageID
            throw error
        }
    }
    
    func ackComments(_ trickleID: TrickleData.ID) async {
        do {
            try await tryAckComments(trickleID)
        } catch {
            self.error = .init(error)
        }
    }
}

// MARK: Atomic Actions
public extension TrickleStore {
    /// Add comment to the specific trickle.
    /// Note that the comment may not be the latest comment due to the network situation.
    /// This function will not change the `nextTS`.
    func addComment(to trickleID: TrickleData.ID, commentData: CommentData) {
        comments.updateValue(commentData, forKey: commentData.commentID)
        tricklesCommentIDs[trickleID] = tricklesCommentIDs[trickleID]?.map { stream in
            var items = stream.items
            let index = items.firstIndex {
                (comments[$0]?.createAt ?? .distantPast) < commentData.createAt
            }
            items.insert(commentData.commentID, at: index ?? items.count)
            return .init(items: items, nextTs: stream.nextTs)
        }
        
        trickles[trickleID]?.commentCounts += 1
    }
    
    /// This function hypothesise `tricklesCommentIDs` is same order as `commentsData` that is from `newer` to `older`.
    func appendComments(to trickleID: TrickleData.ID, commentsData: AnyStreamable<CommentData>) {
        commentsData.items.forEach { comments.updateValue($0, forKey: $0.commentID) }
        tricklesCommentIDs[trickleID] = tricklesCommentIDs[trickleID]?.map { stream in
            return .init(items: stream.items + commentsData.items.map{$0.commentID}, nextTs: commentsData.nextTs)
        }
        trickles[trickleID]?.commentCounts = tricklesComments[trickleID]?.value?.items.filter({$0.typ == .normal}).count ?? 0
    }
    func prependComments(to trickleID: TrickleData.ID, commentsData: AnyStreamable<CommentData>) {
        commentsData.items.forEach { comments.updateValue($0, forKey: $0.commentID) }
        tricklesCommentIDs[trickleID] = tricklesCommentIDs[trickleID]?.map { stream in
            return stream.prepending(commentsData.map{$0.commentID})
        }
        trickles[trickleID]?.commentCounts = tricklesComments[trickleID]?.value?.items.filter({$0.typ == .normal}).count ?? 0
    }
    
    func updateComment(from source: CommentData, to target: CommentData, of trickleID: TrickleData.ID) {
        comments.removeValue(forKey: source.commentID)
        comments[target.commentID] = target
        
        guard let trickleCommentIDs = tricklesCommentIDs[trickleID] else { return }
        tricklesCommentIDs.updateValue(trickleCommentIDs.map {
            $0.updatingItem(from: source.commentID,
                            to: target.commentID)
        }, forKey: trickleID)
    }
    
    func removeComment(_ commentID: CommentData.ID, of trickleID: TrickleData.ID) {
        comments.removeValue(forKey: commentID)
        tricklesCommentIDs[trickleID] = tricklesCommentIDs[trickleID]?.map { $0.removingItem(commentID) }
        trickles[trickleID]?.commentCounts -= 1
    }
}
