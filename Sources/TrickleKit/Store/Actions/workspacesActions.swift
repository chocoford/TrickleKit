//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

public extension TrickleStore {
    /// Load all user's workspaces.
    func loadAllWorkspaces() async {
        guard let userID = userInfo.value??.user.id else { return }
        allWorkspaces.setIsLoading()
        do {
            let data = try await webRepositoryClient.listUserWorkspaces(userID: userID)
            allWorkspaces = .loaded(data: data)
        } catch let error as LoadableError {
            self.error = .lodableError(error)
            allWorkspaces = .failed(error)
        } catch {
            self.error = .unexpected(error)
            allWorkspaces = .failed(.unexpected(error: error))
        }
    }
    
    func createWorkspaceInvitation(workspaceID: String? = nil) async throws -> WorkspaceInvitationData {
        guard let workspaceID = workspaceID ?? currentWorkspaceID,
              let memberData = workspaces[workspaceID]?.userMemberInfo else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        let invitation = try await webRepositoryClient.createWorkspaceInvitation(workspaceID: workspaceID, payload: .init(workspaceID: workspaceID,
                                                                                                                          memberID: memberData.memberID,
                                                                                                                          role: memberData.role,
                                                                                                                          allowedEmailDomains: [],
                                                                                                                          allowedEmails: [],
                                                                                                                          needConfirm: false))
        return invitation.workspaceInvitation
    }
    
    func getWorkspaceInvitations(workspaceID: String? = nil) async throws -> [WorkspaceInvitationData] {
        guard let workspaceID = workspaceID ?? currentWorkspaceID else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        let invitations = try await webRepositoryClient.getWorkspaceInvitations(workspaceID: workspaceID)
        return invitations
    }
    
    func createWorkspace(name: String, userID: String, userName: String, logo: String) async throws {
        let workspaceData = try await webRepositoryClient.createWorkspace(payload: .init(name: name,
                                                                                          userID: userID,
                                                                                          userName: userName,
                                                                                          workspaceType: .team,
                                                                                          logo: logo))
        
        allWorkspaces = .loaded(data: .init(items: ((allWorkspaces.value?.items ?? []) + [workspaceData.workspace]), nextTs: nil))
        currentWorkspaceID = workspaceData.workspace.workspaceID
    }
    
    func updateWorkspaceInfo(workspaceID: String? = nil, name: String?, logo: String?) async {
        do {
            try await tryUpdateWorkspaceInfo(workspaceID: workspaceID, name: name, logo: logo)
        } catch {
            self.error = .init(error)
        }
    }
    
    /// try to update workspace info with specific workspaceID
    /// This function will throws error if updates failed.
    func tryUpdateWorkspaceInfo(workspaceID: String? = nil, name: String?, logo: String?) async throws {
        guard let workspaceID = workspaceID ?? currentWorkspaceID,
              var workspace = workspaces[workspaceID] else {
            throw TrickleStoreError.invalidWorkspaceID(workspaceID)
        }
        
        let oldName = name
        let oldLogo = logo
        if let logo = logo {
            workspace.logo = logo
        }
        if let name = name {
            workspace.name = name
        }
        allWorkspaces = allWorkspaces.map { $0.updatingItem(workspace) }

        do {
            _ = try await webRepositoryClient.updateWorkspace(workspaceID: workspaceID, payload: .init(name: name ?? workspace.name,
                                                                                                       logo: logo ?? workspace.logo,
                                                                                                       memberID: workspace.userMemberInfo.memberID,
                                                                                                       allowedEmailDomains: []))
        } catch {
            if logo != nil {
                workspace.logo = oldLogo!
            }
            if name != nil {
                workspace.name = oldName!
            }
            allWorkspaces = allWorkspaces.map { $0.updatingItem(workspace) }
            throw error
        }
    }
    
    func sendWorkspaceInvitations(workspaceID: String, invitationID: String, memberID: String, url: String, sendTo: [String]) async {
        do {
            _ = try await webRepositoryClient.sendWorkspaceInvitations(workspaceID: workspaceID, invitationID: invitationID, payload: .init(url: url, memberID: memberID, sendTo: sendTo))
        } catch {
            self.error = .init(error)
        }
    }
}
