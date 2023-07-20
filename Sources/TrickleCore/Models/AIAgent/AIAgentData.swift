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
    public let displayName, role, capability, constraints: String
    public let enableChatHistory: Bool
    public let toolInstruction: String
    public let tools: [Tool]
    public let temperature: Double
    public let useChatAPI: Bool
    public let model, formatInstruction, userID, appName: String
    public let appDescription: String
//    public let appActionCards: JSONNull?
    public let appDecoration: AppDecoration?
    public let agentConfigID: String
    public let createAt, updateAt: Int

    enum CodingKeys: String, CodingKey {
        case agent, version, displayName, role, capability, constraints, enableChatHistory, toolInstruction, tools, temperature, useChatAPI, model, formatInstruction
        case userID = "userId"
        case appName, appDescription, appDecoration
        case agentConfigID = "agentConfigId"
        case createAt, updateAt
//         appActionCards,
    }
}

extension AIAgentData: Identifiable {
    public var id: String { agentConfigID }
}

// MARK: - AppDecoration
public struct AppDecoration: Codable, Hashable {
    public let logo: String
    public let placeholder: String
    public let sortIndex: String?

    public init(logo: String, placeholder: String, sortIndex: String?) {
        self.logo = logo
        self.placeholder = placeholder
        self.sortIndex = sortIndex
    }
}

// MARK: - Tool
public struct Tool: Codable, Hashable {
    public let tool, name, description: String
    public let supportReturnDirect, returnDirect, supportOutput: Bool
    public let output: String?
    public let supportLLM: Bool
    public let promptPrefix, promptSuffix: String?
    public let temperature: Double?
    public let model: String?
    public let useChatAPI, useAgentScratchpadAsContext: Bool?
    public let supportIntg: Bool
    public let intg: Intg?
    public let notionSearchDepth: Int?
    public let githubOrgName: String?
    public let githubRepo: String?
    public let supportTxtToImage: Bool
    public let numberOfImages: Int?
    public let imageSize: String?
    public let supportMultiTask: Bool?
    public let supportAgent: Bool
    public let agentConfigID: String?

    enum CodingKeys: String, CodingKey {
        case tool, name, description, supportReturnDirect, returnDirect, supportOutput, output, supportLLM, promptPrefix, promptSuffix, temperature, model, useChatAPI, useAgentScratchpadAsContext, supportIntg, intg, notionSearchDepth, githubOrgName, githubRepo, supportTxtToImage, numberOfImages, imageSize, supportMultiTask, supportAgent
        case agentConfigID = "agentConfigId"
    }

    public init(tool: String, name: String, description: String, supportReturnDirect: Bool, returnDirect: Bool, supportOutput: Bool, output: String, supportLLM: Bool, promptPrefix: String, promptSuffix: String, temperature: Double, model: String, useChatAPI: Bool, useAgentScratchpadAsContext: Bool, supportIntg: Bool, intg: Intg?, notionSearchDepth: Int, githubOrgName: String, githubRepo: String, supportTxtToImage: Bool, numberOfImages: Int, imageSize: String, supportMultiTask: Bool?, supportAgent: Bool, agentConfigID: String) {
        self.tool = tool
        self.name = name
        self.description = description
        self.supportReturnDirect = supportReturnDirect
        self.returnDirect = returnDirect
        self.supportOutput = supportOutput
        self.output = output
        self.supportLLM = supportLLM
        self.promptPrefix = promptPrefix
        self.promptSuffix = promptSuffix
        self.temperature = temperature
        self.model = model
        self.useChatAPI = useChatAPI
        self.useAgentScratchpadAsContext = useAgentScratchpadAsContext
        self.supportIntg = supportIntg
        self.intg = intg
        self.notionSearchDepth = notionSearchDepth
        self.githubOrgName = githubOrgName
        self.githubRepo = githubRepo
        self.supportTxtToImage = supportTxtToImage
        self.numberOfImages = numberOfImages
        self.imageSize = imageSize
        self.supportMultiTask = supportMultiTask
        self.supportAgent = supportAgent
        self.agentConfigID = agentConfigID
    }
}

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

