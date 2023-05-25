//
//  ReactionChange.swift
//  
//
//  Created by Dove Zachary on 2023/5/19.
//

import Foundation

extension TrickleWebSocket {
    @MainActor
    func handleReactionChange(_ event: ChangeNotifyData.LatestChangeEvent.ReactionChangeEvent) {
        switch event {
            case .created(let event):
                self.store?.addReaction(event.eventData.reactionInfo, to: event.eventData.trickleID)
            case .deleted(let event):
                self.store?.removeComment(event.eventData.reactionID, of: event.eventData.trickleID)
            case .commentReactionCreated(let event):
                self.store?.addCommentReaction(event.eventData.reactionInfo, to: event.eventData.commentID)
            case .commentReactionDeleted(let event):
                _ = try? self.store?.removeCommentReaction(reactionID: event.eventData.reactionID, from: event.eventData.commentID)
        }
    }
}
