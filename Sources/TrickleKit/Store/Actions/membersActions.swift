//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

extension TrickleStore {
    /// Load all members of the specific workspace.
    public func loadWorkspaceMembers(_ workspaceID: String?) async {
        guard let workspaceID = workspaceID ?? currentWorkspaceID else { return }
        
        workspacesMembers[workspaceID]?.setIsLoading()
        do {
            let data = try await webRepositoryClient.listWorkspaceMembers(workspaceID: workspaceID)
            workspacesMembers[workspaceID] = .loaded(data: data)
        } catch {
            self.error = .init(error)
            workspacesMembers[workspaceID]?.setAsFailed(error)
        }
    }
}
