//
//  AuthHelper.swift
//  CSWang
//
//  Created by Chocoford on 2022/11/28.
//

import Foundation
import AuthenticationServices
import Combine
import JWTDecode

enum SignInError: Error {
    case invalidURL
    case invalidResponse
    case missSelf
}

public class TrickleAuthHelper: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    static var shared = TrickleAuthHelper()
    
    @Published var running: Bool = false
    
    var cancellables: [AnyCancellable] = []
    
    #if os(macOS)
    public typealias ASPresentationAnchor = NSWindow
    #elseif os(iOS)
    public typealias ASPresentationAnchor = UIWindow
    #endif
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
    
    private func processCallbackUrl(_ callbackURL: URL) throws -> String {
        // The callback URL format depends on the provider. For this example:
        //   exampleauth://auth?token=1234
        let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
        let token = queryItems?.filter({ $0.name == "token" }).first?.value
        guard let token = token else {
            DispatchQueue.main.async {
                self.running = false
            }
            throw SignInError.invalidResponse
        }
        
        return token
    }
    
    @MainActor
    func signIn(to urlString: String, scheme: String) -> AnyPublisher<String, Error> {
        running = true
        guard let authURL = URL(string: urlString) else {
            return Fail(error: SignInError.invalidURL).eraseToAnyPublisher()
        }

        let signinPromise = Future<URL, Error> { completion in
            let session = ASWebAuthenticationSession(url: authURL,
                                                     callbackURLScheme: scheme) { callbackURL, error in
                if let err = error {
                    completion(.failure(err))
                } else if let url = callbackURL {
                    completion(.success(url))
                }

            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
        

        return signinPromise
            .tryMap({ [weak self] in
                guard let this = self else {throw SignInError.missSelf}
                return try this.processCallbackUrl($0)
            })
            .eraseToAnyPublisher()
    }
    
    @MainActor
    public func loginViaBrowser(scheme: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.signIn(to: "https://\(Config.trickleDomain)/app/authorization?third_party=\(scheme)", scheme: scheme).first()
                .sink { result in
                    switch result {
                        case .finished:
                            break
                        case let .failure(error):
                            continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    continuation.resume(with: .success(value))
                }
        }
    }
    
    
}



func decodeToken(token: String) -> TokenInfo? {
    do {
        let jwt = try decode(jwt: token)
        guard let sub = jwt["sub"].string,
              let iat = jwt["iat"].integer,
              let exp = jwt["exp"].integer,
              let scope = jwt["scope"].string else {
            return nil
        }
//        print(TokenInfo(sub: sub, iat: iat, exp: exp, scope: scope, token: token))
        return TokenInfo(sub: sub, iat: iat, exp: exp, scope: scope, token: token)
    } catch {
        return nil
    }

}

func formBearer(with token: String?) -> String? {
    guard let token = token else { return nil }
    return "Bearer " + token
}
