//
//  WorkspaceChange.swift
//  
//
//  Created by Dove Zachary on 2023/5/19.
//

import Foundation
import TrickleSocket

extension TrickleStore {
    @MainActor
    func handleWorkspaceChange(_ changeEvent: TrickleWebSocket.ChangeNotifyData.LatestChangeEvent.WorkspaceChangeEvent) {
        switch changeEvent {
            case .updated(let event):
                guard var workspace = workspaces[event.eventData.workspaceID] else {
                    return
                }
                workspace.update(by: event.eventData.workspaceInfo)
                allWorkspaces = allWorkspaces.map {
                    $0.updatingItem(workspace)
                }
        }
    }
}
