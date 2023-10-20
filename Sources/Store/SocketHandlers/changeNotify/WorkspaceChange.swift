//
//  WorkspaceChange.swift
//  
//
//  Created by Chocoford on 2023/5/19.
//

import Foundation
import TrickleSocketSupport

extension TrickleStore {
    @MainActor
    func handleWorkspaceChange(_ changeEvent: ChangeNotifyData.LatestChangeEvent.WorkspaceChangeEvent) {
        switch changeEvent {
            case .updated(let event):
                guard var workspace = workspaces[event.eventData.workspaceID] else {
                    return
                }
                workspace.update(by: event.eventData.workspaceInfo)
                allWorkspaces = allWorkspaces.map {
                    $0.updatingItem(workspace)
                }
                
            default:
                break
        }
    }
}
