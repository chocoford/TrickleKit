//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/15.
//

import Foundation

// MARK: - AIAgent
public struct AIAgentData: Codable, Hashable {
    public let agent: String
    public let version: Int
    public let isPublished, handleParsingError: Bool
    public let workMode, displayName, role, capability: String
    public let constraints: String
    public let enableChatHistory: Bool
    public let toolInstruction: String
    public let tools: [Tool]
    public let temperature: Double
    public let useChatAPI: Bool
    public let model, formatInstruction, singlePromptFormatInstruction, userID: String
    public let appName, appDescription: String
//    public let appActionCards: JSONNull?
    public let appDecoration: AppDecoration?
    public let category: Category
    public let maxIterations: Int
    public let maxExecutionTime: Int?
    public let earlyStoppingMethod, agentConfigID: String
//    public let createAt, updateAt: Date?

    enum CodingKeys: String, CodingKey {
        case agent, version, isPublished, handleParsingError, workMode, displayName, role, capability, constraints, enableChatHistory, toolInstruction, tools, temperature, useChatAPI, model, formatInstruction, singlePromptFormatInstruction
        case userID = "userId"
        case appName, appDescription, appDecoration, category, maxIterations, maxExecutionTime, earlyStoppingMethod
        // appActionCards,
        case agentConfigID = "agentConfigId"
//        case createAt, updateAt
    }
}

extension AIAgentData: Identifiable {
    public var id: String { agentConfigID }
}

extension AIAgentData {
    // MARK: - AppDecoration
    public struct AppDecoration: Codable, Hashable {
        public let logo: URL?
        public let placeholder: String
        public let sortIndex: String?
        
        public init(logo: URL, placeholder: String, sortIndex: String?) {
            self.logo = logo
            self.placeholder = placeholder
            self.sortIndex = sortIndex
        }
    }
    
    
    // MARK: - Tool
    public struct Tool: Codable, Hashable {
        public let toolConfigID: String?
        //    public let createAt, updateAt: Int
        public let tool, name, description: String
        public let returnDirect, supportOutput, supportReturnDirect, supportLLM: Bool
        public let supportIntg, supportTxtToImage: Bool
        public let supportMultiTask: Bool?
        public let supportAgent, supportLongTermMemory: Bool
        public let version: Int
        public let isPublished: Bool
        public let displayInfo: DisplayInfo
        public let category: Category
        public let agentConfigID: AIAgentData.ID?
        
        enum CodingKeys: String, CodingKey {
            case toolConfigID = "toolConfigId"
            case agentConfigID = "agentConfigId"
            //        case createAt, updateAt
            case tool, name, description, returnDirect, supportOutput, supportReturnDirect, supportLLM, supportIntg, supportTxtToImage, supportMultiTask, supportAgent, supportLongTermMemory, version, isPublished, displayInfo, category
        }
        
        public struct DisplayInfo: Codable, Hashable {
            public let name, description: String
            public let icon: URL?
            
            public init(name: String, description: String, icon: URL?) {
                self.name = name
                self.description = description
                self.icon = icon
            }
        }
        
        public enum Category: String, Codable {
            case basic = "basic"
        }
    }
    
    
    public enum Category: String, Codable {
        case normal = "normal_agent"
        case simplePrompt = "single_prompt_agent"
        case superAgent = "super_agent"
    }
}
extension AIAgentData.Tool { //Identifiable
    public typealias ID = String
//    public var id: String { toolConfigID }
}

extension AIAgentData.Tool {
    // MARK: - Intg
    public struct Intg: Codable, Hashable {
        public let type: String
        public let oauthURL: String
        public let intgID: String?
        
        enum CodingKeys: String, CodingKey {
            case type
            case oauthURL = "oauthUrl"
            case intgID = "intgId"
        }
        
        public init(type: String, oauthURL: String, intgID: String) {
            self.type = type
            self.oauthURL = oauthURL
            self.intgID = intgID
        }
    }
}


extension [AIAgentData] {
    public func sorted() -> Self {
        sorted {
            let a: Int = Int($0.appDecoration?.sortIndex ?? "99999") ?? 99999
            let b: Int = Int($1.appDecoration?.sortIndex ?? "99999") ?? 99999
            return a < b
        }
    }
}
