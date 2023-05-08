//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

public extension TrickleStore {
    func loadMoreComments(_ trickleID: String?, option: LoadMoreOption) async {
        guard let trickleID = trickleID ?? currentTrickleID else { return }
        
        guard let theTrickle = trickles[trickleID],
              let theWorkspace = findGroupWorkspace(theTrickle.groupInfo.groupID) else { return }
        
        tricklesComments[trickleID]?.setIsLoading()
        
        do {
            let data = try await webRepositoryClient.listTrickleComments(workspaceID: theWorkspace.workspaceID,
                                                                        trickleID: trickleID,
                                                                         query: .init(until: tricklesComments[trickleID]?.value?.nextTs ?? Int(Date.now.timeIntervalSince1970),
                                                                                      limit: 20,
                                                                                      order: option == .older ? .desc : .asc))
            tricklesComments[trickleID] = .loaded(data: tricklesComments[trickleID]?.value?.appending(data) ?? data)
        } catch {
            self.error = .init(error)
            tricklesComments[trickleID] = .failed(.init(error))
        }
    }
}

// MARK: Atomic Actions
public extension TrickleStore {
    /// Add comment to the specific trickle.
    /// Note that the comment may not be the latest comment due to the network situation.
    func addComments(to trickleID: TrickleData.ID, commentData: CommentData) {
        tricklesComments[trickleID] = tricklesComments[trickleID]?.map { stream in
            var items = stream.items
            let index = items.firstIndex {
                $0.createAt < commentData.createAt
            }
            items.insert(commentData, at: index ?? items.count)
            return .init(items: items, nextTs: stream.nextTs)
        }
    }
}
