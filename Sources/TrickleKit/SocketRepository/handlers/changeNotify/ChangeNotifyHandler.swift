//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/7.
//

import Foundation
import UserNotifications

extension TrickleWebSocket {
    @MainActor
    func handleChangeNotify(_ data: [TrickleWebSocket.ChangeNotifyData]) {
        for data in data {
            for code in data.codes {
                switch code.value.latestChangeEvent {
                    case .workspace(let workspaceChangeEvent):
                        switch workspaceChangeEvent {
                            case .updated(let event):
                                guard var workspace = self.store?.workspaces[event.eventData.workspaceID] else {
                                    return
                                }
                                workspace.update(by: event.eventData.workspaceInfo)
                                if self.store != nil {
                                    self.store!.allWorkspaces = self.store!.allWorkspaces.map {
                                        $0.updatingItem(workspace)
                                    }
                                }
                        }
                    case .group(_):
                        break
                    case .board(_):
                        break
                    case .view(_):
                        break
                        
                    case .trickle(let trickleChangeEvent):
                        switch trickleChangeEvent {
                            case .created(let event):
                                let workspaceName: String = store?.workspaces[event.eventData.workspaceID]?.name ?? "unknown"
                                let groupName: String = store?.groups[event.eventData.channelID]?.name ?? "unknown"
                                let trickleData: TrickleData = event.eventData.trickleInfo
                                UserNotificationCenter.shared.pushNormalNotification(title: workspaceName,
                                                                                     subtitle: groupName,
                                                                                     body: "\(trickleData.authorMemberInfo.name): \(TrickleEditorParser.getContentDescription(trickleData.blocks))")
                            case .deleted(let event):
                                self.store?.removeTrickle(event.eventData.trickleID, in: store?.groups[event.eventData.receiverID])
                                
                            case .updated(let event):
                                if let oriTrickle = store?.trickles[event.eventData.trickleID] {
                                    store?.updateTrickle(from: oriTrickle, to: event.eventData.trickleInfo)
                                }
                        }
                    case .comment(let commentChangeEvent):
                        switch commentChangeEvent {
                            case .created(let event):
                                self.store?.addComments(to: event.eventData.trickleID, commentData: event.eventData.commentInfo)
                                
                        }
                    case .reaction(_):
                        break
                }
            }
        }
    }
}
