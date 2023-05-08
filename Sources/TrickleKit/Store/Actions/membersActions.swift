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
        } catch let error as LoadableError {
            self.error = .lodableError(error)
            workspacesMembers[workspaceID] = .failed(error)
        } catch {
            self.error = .unexpected(error)
            workspacesMembers[workspaceID] = .failed(.unexpected(error: error))
        }
    }
}
