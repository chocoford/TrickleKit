//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/16.
//

import Foundation

public struct Connection: Codable, Hashable, Identifiable {
    let supportedConnectionID, name, type: String
    let icon: String
    let helpDocURL: String
    let description: Description
    let createAt, updateAt: Date
    
    enum CodingKeys: String, CodingKey {
        case supportedConnectionID = "supportedConnectionId"
        case name, type, icon
        case helpDocURL = "helpDocUrl"
        case description, createAt, updateAt
    }
    
    public var id: String { supportedConnectionID }
}


extension Connection {
    public struct Description: Codable, Hashable {
        public let en, zh: String
    }
}
