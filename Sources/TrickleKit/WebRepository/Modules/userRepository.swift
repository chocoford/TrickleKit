//
//  userRepository.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Combine

extension TrickleWebRepository {
    func getUserData(userID: String) -> AnyPublisher<UserInfo?, Error> {
        call(endpoint: API.getUserData(userID: userID))
    }
    func getUserData(userID: String) async throws -> UserInfo? {
        try await call(endpoint: API.getUserData(userID: userID))
    }
    func loginViaPassword(payload: API.PasswordLoginPayload) async throws -> AuthData {
        try await call(endpoint: API.loginViaPassword(paylaod: payload))
    }
    func sendCode(payload: API.SendCodePayload) async throws -> String {
        try await call(endpoint: API.sendCode(payload: payload))
    }
    
    func updateUserData(userID: UserInfo.UserData.ID, payload: API.UpdateUserDataPayload) async throws -> String {
        try await call(endpoint: API.updateUserData(userID: userID, payload: payload))
    }

    func signup(payload: API.SignupPayload) async throws -> String {
        try await call(endpoint: API.signup(paylaod: payload))
    }
}
