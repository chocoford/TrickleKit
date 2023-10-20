//
//  File.swift
//  
//
//  Created by Chocoford on 2023/5/7.
//

import Foundation
import TrickleSocketSupport

extension TrickleStore {
    @MainActor
    func handleChangeNotify(_ data: [ChangeNotifyData]) {
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
