//
//  SubscriptionChange.swift
//
//
//  Created by Chocoford on 2023/10/20.
//

import Foundation
import TrickleCore
import TrickleSocketSupport

extension TrickleStore {
    @MainActor
    func handleSubscriptionChange(_ event: ChangeNotifyData.LatestChangeEvent.SubscriptionChangeEvent) {
        switch event {
            case .statusChanged(let event):
                allWorkspaces.transform {
                    if  let index = $0.items.firstIndex(where: {$0.workspaceID == event.eventData.workspaceID}) {
                        $0.items[index].subscriptionStatus = event.eventData.status
                    }
                }
                
            case .sessionCompleted(let event):
                break
        }
    }
}
