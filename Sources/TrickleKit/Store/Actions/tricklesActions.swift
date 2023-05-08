//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

public extension TrickleStore {
//    @available(*, deprecated)
//    func loadMoreGroupTrickles(_ groupID: String?, target: LoadMoreOption) async {
//        guard let groupID = groupID ?? currentGroupID else { return }
//        guard let theWorkspace = findGroupWorkspace(groupID) else { return }
//
//        groupsTrickleIDs[groupID]?.setIsLoading()
//
//        do {
//            guard let query = groupsTrickles[groupID]?.value?.nextQuery else { return }
//            let data = try await webRepositoryClient.listGroupTrickles(workspaceID: theWorkspace.workspaceID, groupID: groupID, query: query)
//
//            data.items.forEach { trickleData in
//                trickles[trickleData.trickleID] = trickleData
//            }
//            groupsTrickleIDs[groupID] = .loaded(data: groupsTrickleIDs[groupID]?.value?.appending(data.map{$0.trickleID}) ?? data.map{$0.trickleID})
//        } catch let error as LoadableError {
//            self.error = .lodableError(error)
//            groupsTrickleIDs[groupID] = .failed(error)
//        } catch {
//            self.error = .unexpected(error)
//            groupsTrickleIDs[groupID] = .failed(.unexpected(error: error))
//        }
//    }
    
    func loadMoreViewTrickles(_ viewID: String?, groupByID: FieldOptions.FieldOptionInfo.ID = "NULL", target: LoadMoreOption) async {
        guard let viewID = viewID ?? currentGroupViewID else { return }
        
        guard let group = findViewGroup(viewID),
              let theWorkspace = findGroupWorkspace(group.groupID) else { return }
        
        viewsTrickleIDs[viewID]?[groupByID]?.setIsLoading()
        
        do {
            guard let query = viewsTrickleIDs[viewID]?[groupByID]?.value?.nextQuery else { return }
            let data = try await webRepositoryClient.listGroupTrickles(workspaceID: theWorkspace.workspaceID, groupID: group.groupID, query: query)
            
            data.items.forEach { trickleData in
                trickles[trickleData.trickleID] = trickleData
            }
            viewsTrickleIDs[viewID]?[groupByID] = .loaded(data: viewsTrickleIDs[viewID]?[groupByID]?.value?.appending(data.map{$0.trickleID}) ?? data.map{$0.trickleID})
        } catch {
            self.error = .init(error)
            viewsTrickleIDs[viewID]?[groupByID] = .failed(.init(error))
        }
    }
    /// reset group trickles
    @available(*, deprecated)
    func resetGroupTrickles(_ groupID: String?) {}
    
    func resetViewTrickles(_ viewID: GroupData.ViewInfo.ID?) {
        guard let viewID = viewID ?? currentGroupViewID,
              let view = views[viewID],
              let group = findViewGroup(viewID),
              let workspace = findGroupWorkspace(group.groupID)
        else { return }
        
        if let groupBy = view.groupBy {
            if let stats = viewsTricklesStat[viewID]?.value?.stats {
                viewsTrickleIDs[viewID] = stats.map {
                    [$0.groupID : .loaded(data: .init(items: [],
                                                      nextQuery: .init(memberID: workspace.userMemberInfo.memberID,
                                                                       limit: 20,
                                                                       filters: view.filters,
                                                                       sorts: view.sorts ?? [],
                                                                       groupByFilters: .init(fieldID: groupBy.fieldID,
                                                                                             type: groupBy.type,
                                                                                             value: $0.groupID == "NULL" ? .null : (groupBy.type.isMulti ? .strings([$0.groupID]) : .string($0.groupID)),
                                                                                             operatorID: nil,
                                                                                             filterOperator: groupBy.type.isMulti ? .contains : .eq),
                                                                       filterLogicalOperator: .and)))]
                }
                .merged()
            } else {
                viewsTrickleIDs[viewID] = [:]
            }
        } else {
            viewsTrickleIDs[viewID] = ["NULL" : .loaded(data: .init(items: [],
                                                                    nextQuery: .init(memberID: workspace.userMemberInfo.memberID,
                                                                                     limit: 20,
                                                                                     filters: view.filters,
                                                                                     sorts: view.sorts ?? [],
                                                                                     groupByFilters: nil,
                                                                                     filterLogicalOperator: .and)))]
        }
    }
    
    func tryCopyTrickle(trickleID: TrickleData.ID, to groupID: GroupData.ID, afterTrickleID: TrickleData.ID? = nil) async throws {
        guard var trickle = trickles[trickleID] else { throw TrickleStoreError.trickleNotFound(trickleID) }
        guard let group = findTrickleGroup(trickleID) else { throw TrickleStoreError.FindingError.trickleGroupNotFound(trickleID) }
        guard let workspace = findGroupWorkspace(group.groupID) else { throw TrickleStoreError.FindingError.groupWorkspaceNotFound(group.groupID) }
        
        let tempID = UUID().uuidString
        trickle.trickleID = tempID
        trickle.authorMemberInfo = workspace.userMemberInfo
        trickle.commentCounts = 0
        trickle.reactionInfo = []
        trickle.createAt = .now
        trickle.editAt = nil
        trickle.editBy = nil
        trickle.editingMemberInfo = []
        trickle.viewedMemberInfo = .init(counts: 0, members: [])
        trickle.isPinned = false
        trickle.hasStarred = false
                
        insertTrickle(trickle, to: group, after: afterTrickleID) { viewID in
            viewsTrickleIDs[viewID]?.first(where: { (key, value) in
                value.value?.items.contains(trickleID) == true
            })?.key
        }
        
        do {
            let data = try await webRepositoryClient.copyTrickle(workspaceID: workspace.workspaceID,
                                                                 trickleID: trickleID,
                                                                 payload: .init(oldReceiverID: group.groupID,
                                                                                newReceiverID: groupID,
                                                                                memberID: workspace.userMemberInfo.memberID,
                                                                                afterTrickleID: afterTrickleID))
            var newTrickle = trickle
            newTrickle.trickleID = data.trickleID
            updateTrickle(from: trickle, to: newTrickle, in: group)
        } catch {
            removeTrickle(trickle.trickleID, in: group)
            throw error
        }
    }
    
    func copyTrickle(trickleID: TrickleData.ID, to groupID: GroupData.ID, afterTrickleID: TrickleData.ID? = nil) async {
        do {
             try await tryCopyTrickle(trickleID: trickleID, to: groupID, afterTrickleID: afterTrickleID)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryDuplicateTrickle(trickleID: TrickleData.ID, afterTrickleID: TrickleData.ID? = nil) async throws {
        guard let group = findTrickleGroup(trickleID) else { throw TrickleStoreError.FindingError.trickleGroupNotFound(trickleID) }
        try await tryCopyTrickle(trickleID: trickleID, to: group.groupID)
    }
    
    func duplicateTrickle(trickleID: TrickleData.ID, afterTrickleID: TrickleData.ID? = nil) async {
        do {
            try await tryDuplicateTrickle(trickleID: trickleID, afterTrickleID: afterTrickleID)
        } catch {
            self.error = .init(error)
        }
    }
}


public extension TrickleStore {
    /// Insert the trickle to the specific group after the specific trickle. This function will insert the trickle to every views in the group.
    ///
    /// If not specify `after`, the trickle will be insert to the view's groupBy.
    func insertTrickle(_ trickle: TrickleData, to group: GroupData, after afterID: TrickleData.ID? = nil, toGroupBy: (_ viewID: GroupData.ViewInfo.ID) -> String? = { _ in return "NULL"}) {
        trickles[trickle.trickleID] = trickle
        group.viewInfo.forEach { viewInfo in
            var viewGroupby = "NULL"
            var index = -1
            if let afterID = afterID {
                guard let groupBy = viewsTrickleIDs[viewInfo.viewID]?.first(where: { (key, value) in
                    value.value?.items.contains(afterID) == true
                })?.key else { return }
                viewGroupby = groupBy
                guard let insertIndex = viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.value?.items.firstIndex(of: afterID) else { return }
                index = insertIndex
            } else {
                viewGroupby = toGroupBy(viewInfo.viewID) ?? "NULL"
            }
            viewsTrickleIDs[viewInfo.viewID]?[viewGroupby] = viewsTrickleIDs[viewInfo.viewID]?[viewGroupby]?.map{ .init(items: $0.items.insertingItem(trickle.trickleID, at: index+1),
                                                                                                                        nextQuery: $0.nextQuery) }
        }
    }
    
    /// Update the source trickle found in the group relative to `groupID` to the target trickle. This function will update the trickle in every views in the group.
    func updateTrickle(from source: TrickleData, to target: TrickleData, in group: GroupData? = nil) {
        var group = group
        if group == nil {
            group = findTrickleGroup(source.trickleID)
        }
        trickles.removeValue(forKey: source.trickleID)
        trickles[target.trickleID] = target
        group?.viewInfo.forEach { viewInfo in
            guard let groupBy = viewsTrickleIDs[viewInfo.viewID]?.first(where: { (key, value) in
                value.value?.items.contains(source.trickleID) == true
            })?.key else { return }
            guard let index = viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.value?.items.firstIndex(of: source.trickleID) else { return }
            
            viewsTrickleIDs[viewInfo.viewID]?[groupBy] = viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.map{ .init(items: $0.items.replacingItem(target.trickleID, at: index),
                                                                                                                nextQuery: $0.nextQuery) }
        }
    }
    
    func removeTrickle(_ trickleID: TrickleData.ID, in group: GroupData? = nil) {
        var group = group
        if group == nil {
            group = findTrickleGroup(trickleID)
        }
        trickles.removeValue(forKey: trickleID)
        group?.viewInfo.forEach { viewInfo in
            guard let groupBy = viewsTrickleIDs[viewInfo.viewID]?.first(where: { (key, value) in
                value.value?.items.contains(trickleID) == true
            })?.key else { return }
            guard viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.value?.items.contains(trickleID) == true else { return }

            viewsTrickleIDs[viewInfo.viewID]?[groupBy] = viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.map{ .init(items: $0.items.removingItem(of: trickleID),
                                                                                                                nextQuery: $0.nextQuery) }
        }
    }
}
