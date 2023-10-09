//
//  File.swift
//
//
//  Created by Chocoford on 2023/4/13.
//

import SotoS3 //ensure this module is specified as a dependency in your package.swift
import SotoCognitoIdentity
import SotoSNS
import Foundation
import TrickleCore
import os
import UniformTypeIdentifiers

//

//import AWSCognitoIdentity

public final class TrickleAWSProvider {
    static public let shared = TrickleAWSProvider()

    internal let logger: os.Logger = os.Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TrickleAWSProvider")
    
    internal let bucket = TrickleEnv.ossBucket
    internal let client: AWSClient
    internal var s3: S3
    
    internal var sns: SNS

    internal init() {
        let region: Region = .useast1
        
        let credentialProvider: CredentialProviderFactory = .cognitoIdentity(
            identityPoolId: "us-east-1:f4dd8331-7136-45c8-bbb1-26a539c43002",
            identityProvider: .static(logins: nil),
            region: region
        )
        self.client = AWSClient(credentialProvider: credentialProvider, httpClientProvider: .createNew)
        self.s3 = S3(client: client, region: .useast1)
        
        self.sns = SNS(client: self.client, region: region)
    }
    
    public func restart() {
        let region: Region = .useast1
        self.s3 = S3(client: client, region: region)
        
        self.sns = SNS(client: self.client, region: region)
    }
}




extension TrickleAWSProvider {
    public enum FileType {
        case userAvatar(UserInfo.UserData.ID)
        case userCover(UserInfo.UserData.ID)
        case workspaceLogo(WorkspaceData.ID)
        case groupCover(WorkspaceData.ID, MemberData.ID)
        case resource(UserInfo.UserData.ID, WorkspaceData.ID, _ filename: String)
        
        var path: String {
            switch self {
                case .userAvatar(let userID):
                    return "upload/avatars/users/\(userID)_\(UUID().uuidString)"
                case .userCover(let userID):
                    return "upload/covers/users/\(userID)_\(UUID().uuidString)"
                case .workspaceLogo(let workspaceID):
                    return "upload/avatars/workspaces/\(workspaceID)_\(UUID().uuidString)"
                case .groupCover(let workspaceID, let memberID):
                    return "upload/covers/workspaces/\(workspaceID)/\(memberID)_\(UUID().uuidString)"
                case .resource(let userID, let workspaceID, let filename):
                    return "upload/users/\(userID)/workspaces/\(workspaceID)/\(Int(Date.now.timeIntervalSince1970 * 1000))/\(filename)"
            }
        }
    }
    
    public func uploadFile(at url: URL, type: FileType) async throws -> URL {
        let fileExtension = url.pathExtension
        let data = try Data(contentsOf: url)
        return try await uploadFile(data, type: type, fileExtension: fileExtension)
    }
    
    
    public func uploadFile(
        _ fileData: Data, 
        type: FileType,
        fileExtension: String,
        mineType: String = "application/octet-stream"
    ) async throws -> URL {
        let path = type.path + "." + fileExtension
        let utType = UTType(filenameExtension: fileExtension)?.identifier
        let putObjectRequest = S3.PutObjectRequest(
            acl: .none,
            body: .data(fileData),
            bucket: bucket,
            contentType: utType,
            key: path
        )
        _ = try await s3.putObject(putObjectRequest)
        guard let url = URL(string: "https://\(TrickleEnv.ossAssetsDomain)/\(path)") else {
            throw URLError.init(.badURL)
        }
        return url
    }
    
    public func createEndpoint(_ token: String, customUserData: String? = nil) async throws {
        let topicArn = "arn:aws:sns:us-east-1:257417524232:app/APNS/chocoford_apns"
        let res = try await sns.createPlatformEndpoint(.init(attributes: nil, customUserData: customUserData, platformApplicationArn: topicArn, token: token))
//        let topicArn = res.ß≈endpointArn
//        let subscriptionArn = try await sns.subscribe(SNS.SubscribeInput(attributes: ["FilterPolicy": ""], endpoint: nil, protocol: "", topicArn: ""))
//        try await sns.confirmSubscription(SNS.ConfirmSubscriptionInput(token: "", topicArn: ""))
//        try await sns.setSubscriptionAttributes(SNS.SetSubscriptionAttributesInput(attributeName: "FilterPolicy", attributeValue: "", subscriptionArn: ""))
        print(res)
    }
}
