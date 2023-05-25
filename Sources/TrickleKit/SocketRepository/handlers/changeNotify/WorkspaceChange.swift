//
//  WorkspaceChange.swift
//  
//
//  Created by Dove Zachary on 2023/5/19.
//

import Foundation


extension TrickleWebSocket {
    @MainActor
    func handleWorkspaceChange(_ changeEvent: ChangeNotifyData.LatestChangeEvent.WorkspaceChangeEvent) {
        switch changeEvent {
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
    }
}
