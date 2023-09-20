//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation
import ChocofordEssentials
import TrickleCore
import TrickleAuth

public extension TrickleStore {
    func logout(isSandbox: Bool) {
        Task { await logoutAPNs(isSandbox: isSandbox) }
        TrickleAuthMiddleware.shared.removeToken()
        reinit()
    }
    
    func tryLoadUserInfo() async throws {
        self.userInfo.setIsLoading()
        do {
            guard let token = TrickleAuthMiddleware.shared.token,
                  let tokenInfo = decodeToken(token: token),
                  let userInfo = try await webRepositoryClient.getUserData(userID: tokenInfo.sub) else {
                throw TrickleStoreError.unauthorized
            }
            self.userInfo = .loaded(data: UserInfo(user: userInfo.user, token: token))
            TrickleAuthMiddleware.shared.saveTokenToKeychain(userInfo: self.userInfo.value!!)
        } catch {
            self.userInfo.setAsFailed(error)
            throw error
        }
    }
    
    /// Load the info of currently logged in user.
    func loadUserInfo() async {
        self.userInfo.setIsLoading()
        do {
            try await tryLoadUserInfo()
        } catch {
            self.error = .init(error)
        }
    }

    func tryLoginViaBrowser(scheme: String) async throws {
        let token = try await TrickleAuthHelper.shared.loginViaBrowser(scheme: scheme)
        TrickleAuthMiddleware.shared.token = token
        try await tryLoadUserInfo()
    }
    
    func tryLoginViaPassword(email: String, password: String) async throws {
        do {
            let data = try await webRepositoryClient.loginViaPassword(payload: .init(email: email.lowercased(), password: password))
            TrickleAuthMiddleware.shared.token = data.accessToken
        } catch {
            self.userInfo.setAsFailed(error)
            self.error = .init(error)
            throw error
        }
    }
    
    func loginViaPassword(email: String, password: String) async -> Bool {
        do {
            let data = try await webRepositoryClient.loginViaPassword(payload: .init(email: email.lowercased(), password: password))
            TrickleAuthMiddleware.shared.token = data.accessToken
            return true
        } catch {
            self.userInfo.setAsFailed(error)
            self.error = .init(error)
            return false
        }
    }
    
    func trySendSignupCode(email: String) async throws {
        do {
            _ = try await webRepositoryClient.sendCode(payload: .init(email: email.lowercased(), type: .signUp))
        } catch {
            self.error = .init(error)
            throw error
        }
    }
    
    func sendSignupCode(email: String) async {
        do {
            _ = try await trySendSignupCode(email: email.lowercased())
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryValidateSignup(email: String, code: String) async throws {
        _ = try await webRepositoryClient.signup(payload: .validate(.init(email: email.lowercased(), code: code)))
    }
    
    func trySignup(email: String, code: String, name: String, avatarURL: String, password: String) async throws {
        _ = try await webRepositoryClient.signup(payload: .actualSignup(.init(email: email.lowercased(), code: code, name: name, avatarURL: avatarURL, password: password)))
    }
    
    func tryUpdateUserAvatar(userID: UserInfo.UserData.ID, avatarURL: String) async throws -> String {
        let originalAvatar = userInfo.value??.user.avatarURL ?? ""
        do {
            let data = try await webRepositoryClient.updateUserData(userID: userID, payload: .init(avatarURL: avatarURL))
            userInfo.transform {
                $0?.user.avatarURL = avatarURL
            }
            return data
        } catch {
            userInfo.transform {
                $0?.user.avatarURL = originalAvatar
            }
            throw error
        }
    }

    func updateUserAvatar(userID: UserInfo.UserData.ID, avatarURL: String) async {
        do {
            _ = try await tryUpdateUserAvatar(userID: userID, avatarURL: avatarURL)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryUpdateUserNickname(userID: UserInfo.UserData.ID, nickname: String) async throws -> String {
        let originalName = userInfo.value??.user.name ?? ""
        do {
            let data = try await webRepositoryClient.updateUserData(userID: userID, payload: .init(nickname: nickname))
            userInfo.transform { 
                $0?.user.name = nickname
            }
            return data
        } catch {
            userInfo.transform {
                $0?.user.name = originalName
            }
            throw error
        }
    }
    
    func updateUserNickname(userID: UserInfo.UserData.ID, nickname: String) async {
        do {
            _ = try await webRepositoryClient.updateUserData(userID: userID, payload: .init(nickname: nickname))
        } catch {
            self.error = .init(error)
        }
    }
}
