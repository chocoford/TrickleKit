//
//  CommentChange.swift
//  
//
//  Created by Chocoford on 2023/5/19.
//

import Foundation
import TrickleSocketSupport

extension TrickleStore {
    @MainActor
    func handleCommentChange(_ event: ChangeNotifyData.LatestChangeEvent.CommentChangeEvent) {
        switch event {
            case .created(let event):
                addComment(to: event.eventData.trickleID, commentData: event.eventData.commentInfo)
            case .deleted(let event):
                removeComment(event.eventData.commentID, of: event.eventData.trickleID)
            case .statusCommentCreated(let event):
                addComment(to: event.eventData.trickleID, commentData: event.eventData.commentInfo)
            case .threadsUnreadCountUpdated(let event):
                workspacesThreadsUnreadCount[event.eventData.workspaceID] = event.eventData.threadsUnreadCount
        }
    }
}
