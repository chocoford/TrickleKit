//
//  CommentChange.swift
//  
//
//  Created by Dove Zachary on 2023/5/19.
//

import Foundation

extension TrickleWebSocket {
    @MainActor
    func handleCommentChange(_ event: ChangeNotifyData.LatestChangeEvent.CommentChangeEvent) {
        switch event {
            case .created(let event):
                self.store?.addComment(to: event.eventData.trickleID, commentData: event.eventData.commentInfo)
            case .deleted(let event):
                self.store?.removeComment(event.eventData.commentID, of: event.eventData.trickleID)
            case .statusCommentCreated(let event):
                self.store?.addComment(to: event.eventData.trickleID, commentData: event.eventData.commentInfo)
            case .threadsUnreadCountUpdated(let event):
                self.store?.workspacesThreadsUnreadCount[event.eventData.workspaceID] = event.eventData.threadsUnreadCount
        }
    }
}
