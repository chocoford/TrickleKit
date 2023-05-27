//
//  ReactionChange.swift
//  
//
//  Created by Dove Zachary on 2023/5/19.
//

import Foundation
import TrickleSocket
import TrickleCore

extension TrickleStore {
    @MainActor
    func handleReactionChange(_ event: TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.ReactionChangeEvent) {
        switch event {
            case .created(let event):
                addReaction(event.eventData.reactionInfo, to: event.eventData.trickleID)
            case .deleted(let event):
                removeComment(event.eventData.reactionID, of: event.eventData.trickleID)
            case .commentReactionCreated(let event):
                addCommentReaction(event.eventData.reactionInfo, to: event.eventData.commentID)
            case .commentReactionDeleted(let event):
                _ = try? removeCommentReaction(reactionID: event.eventData.reactionID, from: event.eventData.commentID)
        }
    }
}
