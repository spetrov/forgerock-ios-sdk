//
//  SIWAService.swift
//  FRSocialLogin
//
//  Created by James Go on 1/26/21.
//

import Foundation
import FRAuth
import AuthenticationServices

class SIWAService: SocialLoginService {
    
    var completion: SocialLoginCallback?
    
    override func login(completion: @escaping SocialLoginCallback) {
        if #available(iOS 13.0, *) {
            self.tokenType = "authorization_code"
            self.completion = completion
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        else {
            completion(nil, nil, AuthError.userAuthenticationRequired)
        }
    }
}


extension SIWAService: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            FRLog.w("Cred: \(appleIDCredential)")
            
            if let state = appleIDCredential.state {
                FRLog.w("State: \(state)")
            }
            
            guard let codeData = appleIDCredential.authorizationCode, let code = String(data: codeData, encoding: .utf8) else {
                return
            }
            
            self.completion?(code, self.tokenType, nil)
            break
        case let passwordCredential as ASPasswordCredential:
            FRLog.w("Cred: \(passwordCredential)")
            break
        default:
            break
        }
    }
}

extension SIWAService: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
