//
//  TrickleChange.swift
//  
//
//  Created by Dove Zachary on 2023/5/19.
//

import Foundation

extension TrickleWebSocket {
    @MainActor
    func handleTrickleChange(_ event: ChangeNotifyData.LatestChangeEvent.TrickleChangeEvent) {
        switch event {
            case .created(let event):
                let workspaceName: String = store?.workspaces[event.eventData.workspaceID]?.name ?? "unknown"
                let groupName: String = store?.groups[event.eventData.channelID]?.name ?? "unknown"
                let trickleData: TrickleData = event.eventData.trickleInfo
                UserNotificationCenter.shared.pushNormalNotification(title: workspaceName,
                                                                     subtitle: groupName,
                                                                     body: "\(trickleData.authorMemberInfo.name): \(TrickleEditorParser.getContentDescription(trickleData.blocks))")
                
            case .moved(let event):
                store?.moveTrickle(event.eventData.trickleID, to: event.eventData.channelID)
            case .updated(let event):
                if let oriTrickle = store?.trickles[event.eventData.trickleID] {
                    store?.updateTrickle(from: oriTrickle, to: event.eventData.trickleInfo)
                }
            case .deleted(let event):
                self.store?.removeTrickle(event.eventData.trickleID, in: store?.groups[event.eventData.receiverID])
                
            case .viewed(let event):
                self.store?.addViewedMember(event.eventData.memberID, to: event.eventData.trickleID)
                
            case .pinRankChanged(let event):
                if let trickle = self.store?.trickles[event.eventData.trickleID] {
                    self.store?.addPinTrickle(trickle, to: event.eventData.channelID, afterID: event.eventData.afterTrickleID)
                }
            case .starred(let event):
                store?.trickles[event.eventData.trickleID]?.hasStarred = true
                
            case .unstarred(let event):
                store?.trickles[event.eventData.trickleID]?.hasStarred = false
        }
    }
}
