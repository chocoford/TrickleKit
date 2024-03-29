//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation 
import TrickleCore

public extension TrickleStore {
    // MARK: - List Trickles
    func tryLoadNewerViewTrickles(
        _ viewID: GroupData.ViewInfo.ID,
        groupByID: FieldOptions.FieldOptionInfo.ID = "NULL",
        nextQuery: NextQuery? = nil
    ) async throws {
        // setIsLoading make view been redrawn, which will cancel the refresh processs
        // viewsTrickleIDs[viewID]?[groupByID]?.setIsLoading()
        guard let view = views[viewID] else { throw TrickleStoreError.invalidViewID(viewID) }
        
        let group = try findViewGroup(viewID)
        let workspace = try findGroupWorkspace(group.groupID)
        
        let query: NextQuery = nextQuery ?? .mock(workspace: workspace, view: view, groupByID: groupByID, limit: 20)

        do {
            let data = try await webRepositoryClient.listGroupTrickles(
                workspaceID: workspace.workspaceID,
                groupID: group.groupID,
                query: query
            )
            guard let trickleID = data.items.last?.trickleID else { return }
            let encounterExisted = viewsTrickleIDs[viewID]?[groupByID]?.value?.items.contains(trickleID) == true
            prependTrickles(data, to: viewID)
            if !encounterExisted {
                try await tryLoadNewerViewTrickles(viewID, groupByID: groupByID, nextQuery: data.nextQuery)
            }
        } catch {
            throw error
        }
    }
    
    func tryLoadOlderViewTrickles(
        _ viewID: GroupData.ViewInfo.ID,
        groupByID: FieldOptions.FieldOptionInfo.ID = "NULL",
        since: Date?,
        silent: Bool = false,
        replace: Bool = false
    ) async throws {
        if !silent { viewsTrickleIDs[viewID]?[groupByID]?.setIsLoading() }
        do {
            let group = try findViewGroup(viewID)
            let theWorkspace = try findGroupWorkspace(group.groupID)
            
            let query: NextQuery?
            if let since = since {
                query = .morkFeed(workspace: theWorkspace,
                                  isDescent: true,
                                  since: since,
                                  limit: 20)
            } else {
                query = viewsTrickleIDs[viewID]?[groupByID]?.value?.nextQuery
            }
            
            guard let query = query else { return }
            let data = try await webRepositoryClient.listGroupTrickles(workspaceID: theWorkspace.workspaceID,
                                                                       groupID: group.groupID,
                                                                       query: query)
            
            if replace {
                replaceTrickles(data, to: viewID, groupByID: groupByID)
            } else {
                appendTrickles(data, to: viewID, groupByID: groupByID)
            }
        } catch {
            viewsTrickleIDs[viewID]?[groupByID]?.setAsFailed(error)
            throw error
        }
    }
    
    func loadMoreViewTrickles(
        _ viewID: GroupData.ViewInfo.ID,
        groupByID: FieldOptions.FieldOptionInfo.ID = "NULL",
        target: LoadMoreOption,
        silent: Bool = false
    ) async {
        do {
            let group = try findViewGroup(viewID)
            let workspace = try findGroupWorkspace(group.groupID)
            switch target {
                case .newer(let since):
                    try await tryLoadNewerViewTrickles(
                        viewID,
                        groupByID: groupByID,
                        nextQuery: .morkFeed(workspace: workspace,
                                             isDescent: false,
                                             since: since ?? .now,
                                             limit: 20)
                    )
                case .older(let since):
                    try await tryLoadOlderViewTrickles(viewID, groupByID: groupByID, since: since, silent: silent, replace: false)
                case .refresh:
                    try await tryLoadOlderViewTrickles(viewID, groupByID: groupByID, since: .now, silent: silent, replace: true)
            }
        } catch {
            self.error = .init(error)
        }
    }
    
    // MARK: - List Workspace Trickles
    
    func tryLoadMoreWorkspaceTrickles(
        _ workspaceID: WorkspaceData.ID,
        target: LoadMoreOption,
        silent: Bool = false
    ) async throws {
        if !silent { self.workspacesTrickleIDs[workspaceID]?.setIsLoading() }
        do {
            guard let workspace = self.workspaces[workspaceID] else {
                throw TrickleStoreError.invalidWorkspaceID(workspaceID)
            }
            let query: TrickleWebRepository.API.ListTricklesQuery
            switch target {
                case .older(let since):
                    query = .init(
                        workspaceID: workspaceID,
                        memberID: workspace.userMemberInfo.memberID,
                        until: since ?? self.workspacesTrickleIDs[workspaceID]?.value?.nextTs,
                        limit: 20,
                        order: .desc
                    )
                    
                case .newer(let since):
                    query = .init(
                        workspaceID: workspaceID,
                        memberID: workspace.userMemberInfo.memberID,
                        until: since,
                        limit: 20,
                        order: .asc
                    )
                case .refresh:
                    query = .init(
                        workspaceID: workspaceID,
                        memberID: workspace.userMemberInfo.memberID,
                        until: .now,
                        limit: 20,
                        order: .desc
                    )
            }

            let data = try await webRepositoryClient.listTrickles(
                workspaceID: workspaceID,
                query: query
            )
            
            self._updateTrickles(data.items)
            
            switch target {
                case .older:
                    self.workspacesTrickleIDs[workspaceID] = .loaded(
                        data: self.workspacesTrickleIDs[workspaceID]?.value?.appending(data.map{$0.trickleID}) ?? data.map{$0.trickleID}
                    )
                case .newer:
                    self.workspacesTrickleIDs[workspaceID] = .loaded(
                        data: self.workspacesTrickleIDs[workspaceID]?.value?.prepending(data.map{$0.trickleID}) ?? data.map{$0.trickleID}
                    )
                case .refresh:
                    self.workspacesTrickleIDs[workspaceID] = .loaded(data: data.map{$0.trickleID})
            }
 
        } catch {
            workspacesTrickleIDs[workspaceID]?.setAsFailed(error)
            throw error
        }
    }
    
    func loadMoreWorkspaceTrickles(
        _ workspaceID: WorkspaceData.ID,
        target: LoadMoreOption,
        silent: Bool = false
    ) async {
        do {
            try await self.tryLoadMoreWorkspaceTrickles(workspaceID, target: target, silent: silent)
        } catch {
            self.error = .init(error)
        }
    }
    
    // MARK: - Get Trickle
    /// Get a specific post
    func tryGetTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID) async throws -> TrickleData {
        guard let workspace = workspaces[workspaceID] else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        
        let res = try await webRepositoryClient.listTrickles(
            workspaceID: workspaceID,
            query: .init(workspaceID: workspaceID, trickleID: trickleID, memberID: workspace.userMemberInfo.memberID, limit: 1)
        )
        
        guard let trickle = res.items.first else { throw TrickleStoreError.lodableError(.notFound) }
        
        trickles[trickle.trickleID] = trickle
        
        return trickle
    }
    
    // MARK: - Create Trickle
    func tryCreateTrickle(workspaceID: WorkspaceData.ID? = nil,
                          groupID: GroupData.ID,
                          blocks: [TrickleBlock],
                          mentionedMemberIDs: [MemberData.ID],
                          referTrickleIDs: [TrickleData.ID],
                          medias: [String],
                          files: [String]) async throws -> TrickleData {
        let workspace = try workspaces[workspaceID ?? ""] ?? findGroupWorkspace(groupID)
        
        let author = workspace.userMemberInfo
        do {
            let res = try await webRepositoryClient.createPost(
                workspaceID: workspace.workspaceID,
                groupID: groupID,
                payload: .init(
                    authorMemberID: author.memberID,
                    blocks: blocks,
                    mentionedMemberIDs: mentionedMemberIDs,
                    referTrickleIDs: referTrickleIDs,
                    medias: medias,
                    files: files
                )
            )
            insertTrickle(res)
            return res
        } catch {
            throw error
        }
    }

    // MARK: - Copy Trickle
    func tryCopyTrickle(trickleID: TrickleData.ID, to groupID: GroupData.ID, afterTrickleID: TrickleData.ID? = nil) async throws {
        guard var trickle = trickles[trickleID] else { throw TrickleStoreError.invalidTrickleID(trickleID) }
        let group = try findTrickleGroup(trickleID)
        let workspace = try findGroupWorkspace(group.groupID)
        
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
                
        insertTrickle(trickle, after: afterTrickleID) { viewID in
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
    
    // MARK: - Duplicate Trickle
    func tryDuplicateTrickle(trickleID: TrickleData.ID, afterTrickleID: TrickleData.ID? = nil) async throws {
        let group = try findTrickleGroup(trickleID)
        try await tryCopyTrickle(trickleID: trickleID, to: group.groupID)
    }
    
    func duplicateTrickle(trickleID: TrickleData.ID, afterTrickleID: TrickleData.ID? = nil) async {
        do {
            try await tryDuplicateTrickle(trickleID: trickleID, afterTrickleID: afterTrickleID)
        } catch {
            self.error = .init(error)
        }
    }
    
    // MARK: - Add Trickle Last View
    func tryAddTrickleLastView(trickleID: TrickleData.ID) async throws {
        let workspace = try findTrickleWorkspace(trickleID)
        guard let originalLastViewInfo = trickles[trickleID]?.lastViewInfo else {
            throw TrickleStoreError.invalidTrickleID(trickleID)
        }
        trickles[trickleID]?.lastViewInfo.lastViewedAt = .now
        addViewedMember(workspace.userMemberInfo.memberID, to: trickleID)
        do {
            _ = try await webRepositoryClient.addTrickleLastView(workspaceID: workspace.workspaceID, trickleID: trickleID, payload: .init(memberID: workspace.userMemberInfo.memberID))
        } catch {
            trickles[trickleID]?.lastViewInfo.lastViewedAt = originalLastViewInfo.lastViewedAt
            removeViewedMember(workspace.userMemberInfo.memberID, of: trickleID)
            throw error
        }
    }
    
    func addTrickleLastView(trickleID: TrickleData.ID) async {
        do {
            try await tryAddTrickleLastView(trickleID: trickleID)
        } catch {
            self.error = .init(error)
        }
    }
}


public extension TrickleStore {
    /// reset group trickles
    @available(*, deprecated)
    func resetGroupTrickles(_ groupID: String?) {}
    
    func resetViewTrickles(_ viewID: GroupData.ViewInfo.ID) {
        guard let view = views[viewID],
              let group = try? findViewGroup(viewID),
              let workspace = try? findGroupWorkspace(group.groupID)
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
    
    /// Insert the trickle to the specific view after the specific trickle. ~~This function will insert the trickle to every views in the group.~~
    ///
    /// If not specify `after`, the trickle will be insert to the view's groupBy.
    /// If `after` is specified, the `toGroupBy`
    func insertTrickle(
        _ trickle: TrickleData,
        after afterID: TrickleData.ID? = nil,
        toGroupBy groupBy: (_ viewID: GroupData.ViewInfo.ID) -> String? = { _ in return "NULL"}
    ) {
        trickles[trickle.trickleID] = trickle
        trickle.commentInfo?.forEach {
            self.comments[$0.commentID] = $0
        }
        self.tricklesCommentIDs[trickle.trickleID] = .loaded(
            data: .init(
                items: trickle.commentInfo?.map{$0.commentID} ?? [],
                nextTs: trickle.commentInfo?.last?.createAt
            )
        )
        guard let groupID = trickle.groupInfo.groupID, let group = groups[groupID] else { return }
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
                viewGroupby = groupBy(viewInfo.viewID) ?? "NULL"
            }
            viewsTrickleIDs[viewInfo.viewID]?[viewGroupby] = viewsTrickleIDs[viewInfo.viewID]?[viewGroupby]?.map{ .init(items: $0.items.insertingItem(trickle.trickleID, at: index+1),
                                                                                                                        nextQuery: $0.nextQuery) }
        }
        
        // also insert to workspace trickles
        guard let worksapce = try? findTrickleWorkspace(trickle.trickleID) else { return }
        self.workspacesTrickleIDs[worksapce.workspaceID] = self.workspacesTrickleIDs[worksapce.workspaceID]?.map {
            .init(items: $0.items.insertingItem(trickle.trickleID, at: 0), nextTs: $0.nextTs)
        }
    }
    
    /// Update the source trickle found in the group relative to `groupID` to the target trickle. This function will update the trickle in every views in the group.
    func updateTrickle(from source: TrickleData, to target: TrickleData, in group: GroupData? = nil) {
        var group = group
        if group == nil {
            group = try? findTrickleGroup(source.trickleID)
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
    
    func moveTrickle(_ trickleID: TrickleData.ID, to targetGroupID: GroupData.ID) {
        guard let trickle = trickles[trickleID],
              let group = try? findTrickleGroup(trickleID) else { return }
        
        removeTrickle(trickleID, in: group)
        insertTrickle(trickle)
    }
    
    func removeTrickle(_ trickleID: TrickleData.ID, in group: GroupData? = nil) {
        var group = group
        if group == nil {
            group = try? findTrickleGroup(trickleID)
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
    
    /// Append trickles to `viewTrickles`. Normally, it will append the trickles directly to current `viewTrickles`.
    /// Once duplication is detected, it will replace the original `viewTrickles` from occurance's start to its end.
    /// - Parameters:
    ///   - trickles: The trickles want to be appended.
    ///   - viewID: The ID of incoming trickles' view.
    ///   - groupByID: The groupByID of incoming trickles. defaults to `NULL`, which means no groupBy was applied.
    ///   - replace: <#replace description#>
    func appendTrickles(_ trickles: AnyQueryStreamable<TrickleData>,
                        to viewID: GroupData.ViewInfo.ID,
                        groupByID: FieldOptions.FieldOptionInfo.ID = "NULL",
                        replace: Bool = false) {
        _updateTrickles(trickles.items)
        
        let trickleIDs = trickles.map{ $0.trickleID }
        
        viewsTrickleIDs[viewID]?[groupByID] = .loaded(
            data: viewsTrickleIDs[viewID]?[groupByID]?.value?.appending(trickleIDs, replace: replace) ?? trickleIDs
        )
    }
    
    /// Prepend trickles to `viewTrickles`. Normally, it will prepend trickles directly to current `viewTrickles`.
    /// ~~Once duplication is detected, it will replace the original `viewTrickles` from occurance's start to its end.~~
    /// Once duplication is detected, it will remove the original duplicated trickle.
    /// - Parameters:
    ///   - trickles: Trickles that will be prepended.
    ///   - viewID: The target view's id.
    ///   - groupByID: The groupBy id of the target view.
    func prependTrickles(_ trickles: AnyQueryStreamable<TrickleData>,
                         to viewID: GroupData.ViewInfo.ID,
                         groupByID: FieldOptions.FieldOptionInfo.ID = "NULL") {
        _updateTrickles(trickles.items)
        let trickleIDs = trickles.map{$0.trickleID}
        viewsTrickleIDs[viewID]?[groupByID] = .loaded(data: viewsTrickleIDs[viewID]?[groupByID]?.value?.prepending(trickleIDs) ?? trickleIDs)
    }
    
    /// Replace all the trickles in the specific view.
    func replaceTrickles(_ trickles: AnyQueryStreamable<TrickleData>,
                         to viewID: GroupData.ViewInfo.ID,
                         groupByID: FieldOptions.FieldOptionInfo.ID = "NULL") {
        _updateTrickles(trickles.items)
        let trickleIDs = trickles.map{$0.trickleID}
        viewsTrickleIDs[viewID]?[groupByID] = .loaded(
            data: trickleIDs
        )
    }
    
    func addViewedMember(_ memberID: MemberData.ID, to trickleID: TrickleData.ID) {
        if trickles[trickleID]?.viewedMemberInfo.members.contains(where: {$0.memberID == memberID}) == true {
            return
        }
        
        guard let memberData = members[memberID] else { return }
        
        trickles[trickleID]?.viewedMemberInfo.counts += 1
        trickles[trickleID]?.viewedMemberInfo.members.append(memberData)
    }
    
    func removeViewedMember(_ memberID: MemberData.ID, of trickleID: TrickleData.ID) {
        guard trickles[trickleID]?.viewedMemberInfo.members.contains(where: {$0.memberID == memberID}) == true else {
            return
        }
                
        trickles[trickleID]?.viewedMemberInfo.members.removeAll(where: {$0.memberID == memberID})
        trickles[trickleID]?.viewedMemberInfo.counts -= trickles[trickleID]?.viewedMemberInfo.members.count ?? 0
    }
}


internal extension TrickleStore {
    /// Just update trickles info of store's `trickles` property.
    func _updateTrickles(_ trickles: [TrickleData]) {
        trickles.forEach { trickleData in
            self.trickles.updateValue(trickleData, forKey: trickleData.trickleID)
            if trickleData.commentInfo != nil {
                self.tricklesCommentIDs[trickleData.trickleID] = .loaded(
                    data: .init(items: trickleData.commentInfo?.map{$0.commentID} ?? [],
                                nextTs: trickleData.commentInfo?.last?.createAt)
                )
                trickleData.commentInfo?.forEach({ comment in
                    self.comments.updateValue(comment, forKey: comment.commentID)
                })
            }
        }
    }
}
