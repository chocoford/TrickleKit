//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

extension TrickleStore {
    public func listGroupViewTricklesStat(_ viewID: GroupData.ViewInfo.ID?) async {
        guard let viewID = viewID ?? currentGroupViewID,
              let view = views[viewID],
              let group = findViewGroup(viewID),
              let workspace = findGroupWorkspace(group.groupID)
        else { return }
        
        viewsTricklesStat[viewID] = .isLoading(last: viewsTricklesStat[viewID]?.value)
        
        guard let groupBy = view.groupBy else {
            viewsTricklesStat[viewID] = .loaded(data: .empty)
            return
        }
        
        do {
            let stat = try await webRepositoryClient.listGroupViewTricklesStat(workspaceID: workspace.workspaceID,
                                                                               groupID: group.groupID,
                                                                               query: .init(groupBy: .init(fieldId: groupBy.fieldID,
                                                                                                           type: groupBy.type,
                                                                                                           groups: []),
                                                                                            filterLogicalOperator: view.filterLogicalOperator,
                                                                                            filters: view.filters ?? []))
            
            viewsTricklesStat[viewID] = .loaded(data: stat)
            resetViewTrickles(viewID)
        } catch let error as LoadableError {
            self.error = .lodableError(error)
            viewsTricklesStat[viewID] = .failed(error)
        } catch {
            self.error = .unexpected(error)
            viewsTricklesStat[viewID] = .failed(.unexpected(error: error))
        }
    }
}
