//
//  File.swift
//
//
//  Created by Chocoford on 2023/4/13.
//

//import SotoS3 //ensure this module is specified as a dependency in your package.swift
//import SotoCognitoIdentity
//import SotoSNS
import Foundation
import TrickleCore
import OSLog
import UniformTypeIdentifiers

import SotoS3
import SotoCognitoIdentity


//import AWSS3
//import AWSCognitoIdentity
//import AWSClientRuntime
//import AwsCommonRuntimeKit

//struct TrickleAWSCredentials: CredentialsProviding {
//    func getCredentials() async throws -> Credentials {
//        struct InvalidCredentialsError : Error {}
//
//        let cognitoClient = try CognitoIdentityClient(region: "us-east-1")
//        
//        // get a cognito identity id, only one per user and we cache it in user preferences
//        var identityId = UserDefaults.standard.string(forKey: "TrickleAWS-identity-id")
//        if identityId == nil {
//            let cognitoGetIdRequest = GetIdInput(identityPoolId: "us-east-1:f4dd8331-7136-45c8-bbb1-26a539c43002")
//            let cognitoGetIdResponse = try await cognitoClient.getId(input: cognitoGetIdRequest)
//            identityId = cognitoGetIdResponse.identityId
//            UserDefaults.standard.setValue(identityId, forKey: "TrickleAWS-identity-id")
//        }
//        
//        // get aws credentials for that identity
//        let cognitoRequest = GetCredentialsForIdentityInput(identityId: identityId)
//        let cognitoResponse = try await cognitoClient.getCredentialsForIdentity(input: cognitoRequest)
//        
//        guard let credentials = cognitoResponse.credentials,
//              let accessKeyId = credentials.accessKeyId,
//              let secretKey = credentials.secretKey,
//              let sessionToken = credentials.sessionToken else {
//            print("no credentials returned")
//            throw InvalidCredentialsError()
//        }
//        
//        return try Credentials(
//            accessKey: accessKeyId,
//            secret: secretKey,
//            sessionToken: sessionToken
//        )
//    }
//}

public final class TrickleAWSProvider {
    static public let shared = TrickleAWSProvider()

    internal let logger: os.Logger = os.Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TrickleAWSProvider")

    internal let bucket = TrickleEnv.ossBucket
    internal var s3: SotoS3.S3

    internal init() {
        let region: String = "us-east-1"
//        let configuration = try! S3Client.S3ClientConfiguration(region: region)
//        
//        self.s3 = S3Client(config: configuration)
        
        self.s3 = .init(
            client: AWSClient(
                credentialProvider: .cognitoIdentity(
                    identityPoolId: "us-east-1:f4dd8331-7136-45c8-bbb1-26a539c43002",
                    logins: nil,
                    region: Region(rawValue: region)
                )
            ),
            region: Region(rawValue: region)
        )
    }
    
    public func restart() async {
//        try? await withCheckedThrowingContinuation { continuation in
//            self.client.shutdown { error in
//                if let error = error {
//                    self.logger.error("Restart error: \(error.localizedDescription, privacy: .public)")
//                    continuation.resume(throwing: error)
//                } else {
//                    let region: Region = .useast1
//                    
//                    let credentialProvider: CredentialProviderFactory = .cognitoIdentity(
//                        identityPoolId: "us-east-1:f4dd8331-7136-45c8-bbb1-26a539c43002",
//                        identityProvider: .static(logins: nil),
//                        region: region
//                    )
//                    self.client = AWSClient(credentialProvider: credentialProvider, httpClientProvider: .createNew)
//                    self.s3 = S3(client: self.client, region: region)
//                    self.sns = SNS(client: self.client, region: region)
//                    continuation.resume()
//                }
//            }
//        } as Void
//
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
        return try await uploadFile(data: data, type: type, fileExtension: fileExtension)
    }
    
    
    public func uploadFile(
        data fileData: Data,
        type: FileType,
        fileExtension: String,
        mineType: String = "application/octet-stream"
    ) async throws -> URL {
        let path = type.path + "." + fileExtension
        let utType = UTType(filenameExtension: fileExtension)?.identifier
//        let putObjectRequest = PutObjectInput(
//            acl: .none,
//            body: .data(fileData),
//            bucket: bucket,
//            contentType: utType,
//            key: path
//        )
//        _ = try await s3.putObject(input: putObjectRequest)
        let putObjectRequest = S3.PutObjectRequest(
            acl: .none,
            body: .init(buffer: .init(data: fileData)),
            bucket: bucket,
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
//        let res = try await sns.createPlatformEndpoint(.init(attributes: nil, customUserData: customUserData, platformApplicationArn: topicArn, token: token))
//        let topicArn = res.ß≈endpointArn
//        let subscriptionArn = try await sns.subscribe(SNS.SubscribeInput(attributes: ["FilterPolicy": ""], endpoint: nil, protocol: "", topicArn: ""))
//        try await sns.confirmSubscription(SNS.ConfirmSubscriptionInput(token: "", topicArn: ""))
//        try await sns.setSubscriptionAttributes(SNS.SetSubscriptionAttributesInput(attributeName: "FilterPolicy", attributeValue: "", subscriptionArn: ""))
//        print(res)
    }
}
