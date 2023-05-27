//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/7.
//

import Foundation
import TrickleSocket

extension TrickleStore {
    @MainActor
    func handleChangeNotify(_ data: [TrickleWebSocket.ChangeNotifyData]) {
        for data in data {
            for code in data.codes {
                switch code.value.latestChangeEvent {
                    case .workspace(let event):
                        handleWorkspaceChange(event)
                    case .group(_):
                        break
                    case .board(_):
                        break
                    case .view(_):
                        break
                    case .trickle(let event):
                        handleTrickleChange(event)
                    case .comment(let event):
                        handleCommentChange(event)
                    case .reaction(_):
                        break
                }
            }
        }
    }
}
