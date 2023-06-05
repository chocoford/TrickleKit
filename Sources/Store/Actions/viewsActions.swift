//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation
import TrickleCore

public extension TrickleStore {
    func tryListGroupViewTricklesStat(_ viewID: GroupData.ViewInfo.ID, silent: Bool = false) async throws {
        guard let view = views[viewID] else { throw TrickleStoreError.invalidViewID(viewID) }
        
        if !silent { viewsTricklesStat[viewID]?.setIsLoading() }
        
        guard let groupBy = view.groupBy else {
            viewsTricklesStat[viewID] = .loaded(data: .empty)
            return
        }
        
        do {
            let group = try findViewGroup(viewID)
            let workspace = try findGroupWorkspace(group.groupID)
            let stat = try await webRepositoryClient.listGroupViewTricklesStat(workspaceID: workspace.workspaceID,
                                                                               groupID: group.groupID,
                                                                               query: .init(groupBy: .init(fieldId: groupBy.fieldID,
                                                                                                           type: groupBy.type,
                                                                                                           groups: []),
                                                                                            filterLogicalOperator: view.filterLogicalOperator,
                                                                                            filters: view.filters ?? []))
            
            viewsTricklesStat[viewID] = .loaded(data: stat)
            resetViewTrickles(viewID)
        } catch {
            viewsTricklesStat[viewID]?.setAsFailed(error)
            throw error
        }
    }
    
    func listGroupViewTricklesStat(_ viewID: GroupData.ViewInfo.ID, silent: Bool = false) async {
        do {
          try await tryListGroupViewTricklesStat(viewID, silent: silent)
        } catch {
            self.error = .init(error)
        }
    }
}
