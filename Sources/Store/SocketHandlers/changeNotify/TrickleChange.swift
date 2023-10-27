//
//  TrickleChange.swift
//  
//
//  Created by Chocoford on 2023/5/19.
//

import Foundation
import TrickleCore
import TrickleSocketSupport

extension TrickleStore {
    @MainActor
    func handleTrickleChange(_ event: ChangeNotifyData.LatestChangeEvent.TrickleChangeEvent) {
        switch event {
            case .created:
//                let workspaceName: String = workspaces[event.eventData.workspaceID]?.name ?? "unknown"
//                let groupName: String = groups[event.eventData.channelID]?.name ?? "unknown"
//                let trickleData: TrickleData = event.eventData.trickleInfo
//                UserNotificationCenter.shared.pushNormalNotification(title: workspaceName,
//                                                                     subtitle: groupName,
//                                                                     body: "\(trickleData.authorMemberInfo.name): \(TrickleEditorParser.getContentDescription(trickleData.blocks))")
//                self.aiAgentState.captureAgentMessages
                
                break
                
            case .moved(let event):
                moveTrickle(event.eventData.trickleID, to: event.eventData.channelID)
            case .updated(let event):
                if let oriTrickle = trickles[event.eventData.trickleID] {
                    updateTrickle(from: oriTrickle, to: event.eventData.trickleInfo)
                }
            case .deleted(let event):
                removeTrickle(event.eventData.trickleID, in: groups[event.eventData.receiverID])
                
            case .viewed(let event):
                addViewedMember(event.eventData.memberID, to: event.eventData.trickleID)
                
            case .pinRankChanged(let event):
                if let trickle = trickles[event.eventData.trickleID] {
                    addPinTrickle(trickle, to: event.eventData.channelID, afterID: event.eventData.afterTrickleID)
                }
            case .starred(let event):
                trickles[event.eventData.trickleID]?.hasStarred = true
                
            case .unstarred(let event):
                trickles[event.eventData.trickleID]?.hasStarred = false
        }
    }
}
