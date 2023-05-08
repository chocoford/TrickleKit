//
//  StorePreview.swift
//  
//
//  Created by Dove Zachary on 2023/5/2.
//

import Foundation
#if DEBUG
extension TrickleStore {
    public static var preview: TrickleStore = {
        let store = TrickleStore()
        
        store.userInfo = .notRequested // .loaded(data: load("user.json"))
        
        store.allWorkspaces = .loaded(data: load("workspaces.json"))
        store.currentWorkspaceID = store.allWorkspaces.value?.items.first?.workspaceID
        
        store.workspacesGroups = [store.currentWorkspaceID! : .loaded(data: load("groups.json"))]
        store.currentGroupID = "264823540841447430" // store.currentWorkspaceGroups.value?.team.first(where: {$0.}) "909371267092578310" //
        
        store.groupsFieldsOptions = [store.currentGroupID! : .loaded(data: load("fieldsOptions.json"))]
        
        store.currentGroupViewID = "909308866452701221" // "909371301452398629" //

        store.viewsTricklesStat = [store.currentGroupViewID! : .loaded(data: load("stat.json"))]
        
        let trickles: AnyQueryStreamable<TrickleData> = load("trickles.json")
        let threads: AnyStreamable<TrickleData> = load("threads.json")
        store.trickles = formDic(payload: trickles.items, id: \.trickleID)
        store.viewsTrickleIDs[store.currentGroupViewID!] = ["NULL" : .loaded(data: trickles.map{$0.trickleID})]
//        store.groupsTrickleIDs = [store.currentGroupID! : .loaded(data: trickles.map{$0.trickleID})]
        store.workspaceThreadIDs = [store.currentWorkspaceID! : .loaded(data: threads.map{$0.trickleID})]
        
        store.currentTrickleID = store.trickles.values.first?.trickleID
        
        store.tricklesComments = [store.currentTrickleID! : .loaded(data: load("comments.json"))]
        
        store.workspacesMembers = [store.currentWorkspaceID! : .loaded(data: load("members.json"))]
        
        let pins = (load("pins.json") as AnyStreamable<TrickleData>).items
        store.groupsPinTrickleIDs = [store.currentGroupID! : pins.map{$0.trickleID}]
        store.trickles.merge(pins.formDic(\.trickleID), uniquingKeysWith: {$1})
        return store
    }()
}
#endif
