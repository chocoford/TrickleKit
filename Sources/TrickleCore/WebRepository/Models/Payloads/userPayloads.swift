//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/20.
//

import Foundation

extension TrickleWebRepository.API {
    struct PasswordLoginPayload: FormDataPayload {
        var boundary: String = UUID().uuidString
        let grantType: String = "email_password"
        var email: String
        var password: String
        
        enum CodingKeys: String, CodingKey {
            case email, password
            case grantType = "grant_type"
        }
    }
    
    struct SendCodePayload: Codable {
        let email: String
        let type: CodeType
        
        enum CodeType: String, Codable {
            case signUp
            case reset
            case login
        }
    }
    
    enum SignupPayload: Codable {
        case validate(ValidateForm)
        case actualSignup(SignupForm)
        
        struct ValidateForm: FormDataPayload {
            var boundary: String = UUID().uuidString
            let signupType: String = "email_code"
            let validateOnly: Bool = true
            var email: String
            var code: String

            enum CodingKeys: String, CodingKey {
                case email, code
                case validateOnly = "validate_only"
                case signupType = "signup_type"
            }
        }
        
        struct SignupForm: FormDataPayload {
            var boundary: String = UUID().uuidString
            let signupType: String = "email_code"
            var email: String
            var code: String
            var name: String
            var avatarURL: String
            var password: String
            
            enum CodingKeys: String, CodingKey {
                case email, code
                case signupType = "signup_type"
                case name = "nickname"
                case avatarURL = "avatar_url"
                case password
            }
        }
    }
    
    struct UpdateUserDataPayload: Codable {
        let updateMask: UpdateMask
        let avatarURL: String?
        let nickname: String?
        
        enum CodingKeys: String, CodingKey {
            case updateMask
            case avatarURL = "avatarUrl"
            case nickname
        }
        
        enum UpdateMask: String, Codable {
            case nickname
            case avatarURL = "avatarUrl"
        }
        
        init(avatarURL: String) {
            self.updateMask = .avatarURL
            self.avatarURL = avatarURL
            self.nickname = nil
        }
        
        init(nickname: String) {
            self.updateMask = .nickname
            self.avatarURL = nil
            self.nickname = nickname
        }
    }
}
