//
//  File.swift
//
//
//  Created by Chocoford on 2023/4/13.
//

import SotoS3 //ensure this module is specified as a dependency in your package.swift
import SotoCognitoIdentity
import Foundation
//

//import AWSCognitoIdentity

public final class TrickleAWSProvider {
    static public let shared = TrickleAWSProvider()

    internal let bucket = Config.ossBucket
    internal let client: AWSClient
    internal let s3: S3

    internal init() {
        let credentialProvider: CredentialProviderFactory = .cognitoIdentity(identityPoolId: "us-east-1:f4dd8331-7136-45c8-bbb1-26a539c43002",
                                                                             identityProvider: .static(logins: nil),
                                                                             region: .useast1)
        self.client = .init(credentialProvider: credentialProvider, httpClientProvider: .createNew)
        self.s3 = S3(client: client, region: .useast1)
    }


//    func createBucketPutGetObject() async throws -> S3.GetObjectOutput {
//        // Create Bucket, Put an Object, Get the Object
//        let createBucketRequest = S3.CreateBucketRequest(bucket: bucket)
//        _ = try await s3.createBucket(createBucketRequest)
//        // Upload text file to the s3
//        let bodyData = "hello world"
//        let putObjectRequest = S3.PutObjectRequest(
//            acl: .publicRead,
//            body: .string(bodyData),
//            bucket: bucket,
//            key: "hello.txt"
//        )
//        _ = try await s3.putObject(putObjectRequest)
//        // download text file just uploaded to S3
//        let getObjectRequest = S3.GetObjectRequest(bucket: bucket, key: "hello.txt")
//        let response = try await s3.getObject(getObjectRequest)
//        // print contents of response
//        if let body = response.body?.asString() {
//            print(body)
//        }
//        return response
//    }
//
//    init() {
//        let cognitoIdentityClient = try CognitoIdentityClient(region: "us-east-1")
//        let cognitoInputCall = CreateIdentityPoolInput(developerProviderName: "com.amazonaws.mytestapplication",
//                                                        identityPoolName: "identityPoolMadeWithSwiftSDK")
//
//        let result = try await cognitoIdentityClient.createIdentityPool(input: cognitoInputCall)
//        return result
//    }
//
//    func createIdentityPool() async throws -> CreateIdentityPoolOutputResponse {
//        let cognitoIdentityClient = try CognitoIdentityClient(region: "us-east-1")
//        let cognitoInputCall = CreateIdentityPoolInput(developerProviderName: "com.amazonaws.mytestapplication",
//                                                        identityPoolName: "identityPoolMadeWithSwiftSDK")
//
//        let result = try await cognitoIdentityClient.createIdentityPool(input: cognitoInputCall)
//        return result
//    }
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
    
    
    public func uploadFile(_ fileData: Data, type: FileType, fileExtension: String) async throws -> URL {
        let path = type.path + "." + fileExtension
        let putObjectRequest = S3.PutObjectRequest(
            acl: .publicRead,
            body: .data(fileData),
            bucket: bucket,
            key: path
        )
        _ = try await s3.putObject(putObjectRequest)
        guard let url = URL(string: "https://\(Config.ossAssetsDomain)/\(path)") else {
            throw URLError.init(.badURL)
        }
        return url
    }
    
    
}
