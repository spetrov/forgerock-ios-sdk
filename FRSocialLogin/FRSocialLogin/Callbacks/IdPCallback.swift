//
//  IdPCallback.swift
//  FRSocialLogin
//
//  Created by James Go on 1/26/21.
//

import Foundation
import FRAuth
import FBSDKLoginKit
import AuthenticationServices
import GoogleSignIn
import FacebookLogin

public class IdPCallback: MultipleValuesCallback {

    var idpClient: IdpClient
    var service: SocialLoginService
    var completion: SocialLoginCallback?
    var tokenType: String = ""
    var tokenTypeKey: String
    var tokenKey: String
    
    public required init(json: [String : Any]) throws {
        
        guard let callbackType = json["type"] as? String else {
            throw AuthError.invalidCallbackResponse(String(describing: json))
        }
        
        guard let outputs = json["output"] as? [[String: Any]], let inputs = json["input"] as? [[String: Any]] else {
                throw AuthError.invalidCallbackResponse(String(describing: json))
        }
        
        var providerValue: String?
        var clientIdValue: String?
        var redirectUriValue: String?
        var scopeValues: [String]?
        var nonceValue: String?
        
        for output in outputs {
            if let outputName = output["name"] as? String, outputName == "provider", let outputValue = output["value"] as? String {
                providerValue = outputValue
            }
            else if let outputName = output["name"] as? String, outputName == "clientId", let outputValue = output["value"] as? String {
                clientIdValue = outputValue
            }
            else if let outputName = output["name"] as? String, outputName == "redirectUri", let outputValue = output["value"] as? String {
                redirectUriValue = outputValue
            }
            else if let outputName = output["name"] as? String, outputName == "nonce", let outputValue = output["value"] as? String {
                nonceValue = outputValue
            }
            else if let outputName = output["name"] as? String, outputName == "scopes", let outputValue = output["value"] as? [String] {
                scopeValues = outputValue
            }
        }
        
        guard let provider = providerValue else {
            throw AuthError.invalidCallbackResponse("Missing provider value")
        }
        guard let clientId = clientIdValue else {
            throw AuthError.invalidCallbackResponse("Missing client_id value")
        }
        guard let redirect_uri = redirectUriValue else {
            throw AuthError.invalidCallbackResponse("Missing redirect_uri value")
        }
        
        self.tokenKey = ""
        self.tokenTypeKey = ""
        for input in inputs {
            if let name = input["name"] as? String, name.hasSuffix("token") {
                self.tokenKey = name
            } else if let name = input["name"] as? String, name.hasSuffix("token_type") {
                self.tokenTypeKey = name
            }
        }
        
        self.idpClient = IdpClient(provider: provider, clientId: clientId, redirectUri: redirect_uri, nonce: nonceValue, scopes: scopeValues)
        self.service = SocialLoginService.createService(idpClient: idpClient)
            
        try super.init(json: json)
        self.type = callbackType
        self.response = json
    }
    
    public func performLogin(completion: @escaping SocialLoginCallback) {
        self.completion = completion
        
        if self.idpClient.provider.lowercased() == "apple", #available(iOS 13.0, *) {
            self.tokenType = "authorization_code"
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = self.idpClient.nonce
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        else if self.idpClient.provider.lowercased() == "facebook" || self.idpClient.provider.lowercased() == "nativefb" {
            self.tokenType = "access_token"
            let fbManager = LoginManager()
            var fbPermissions: Set<Permission> = []
            for scope in idpClient.scopes ?? [] {
                let fbPermission = Permission(stringLiteral: scope)
                fbPermissions.insert(fbPermission)
            }
            
            let scopes = self.idpClient.scopes ?? []
            fbManager.logIn(permissions: scopes, from: nil) { (result, error) in
                self.inputValues[self.tokenKey] = result?.token?.tokenString
                self.inputValues[self.tokenTypeKey] = self.tokenType
                completion(result?.token?.tokenString, self.tokenType, error)
            }
        }
        else if self.idpClient.provider.lowercased() == "google" {
            self.tokenType = "id_token"
            if let vc = IdPCallback.getCurrentViewController() {
                GIDSignIn.sharedInstance()?.presentingViewController = vc
            }
            GIDSignIn.sharedInstance()?.clientID = self.idpClient.clientId
            GIDSignIn.sharedInstance()?.delegate = self
            GIDSignIn.sharedInstance()?.signIn()
        }
        
//        self.service.login { (token, tokenType, error) in
//            FRLog.w("Token: \(token ?? "") || Token Type: \(tokenType ?? "") || Error: \(error?.localizedDescription ?? "")")
//            completion(token, tokenType, error)
//        }
    }
    
    open override func buildResponse() -> [String : Any] {
        var responsePayload = self.response
        
        var input: [[String: Any]] = []
        for (key, val) in self.inputValues {
            input.append(["name": key, "value": val])
        }
        responsePayload["input"] = input
        return responsePayload
    }
}


extension IdPCallback {
    static func getCurrentViewController() -> UIViewController? {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var rootVC = window?.rootViewController {
            while let presentedVC = rootVC.presentedViewController {
                rootVC = presentedVC
            }
            return rootVC
        }
        return nil
    }
}


extension IdPCallback: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            FRLog.w("Cred: \(appleIDCredential)")
            
            if let state = appleIDCredential.state {
                FRLog.w("State: \(state)")
            }
            
            guard let codeData = appleIDCredential.authorizationCode, let code = String(data: codeData, encoding: .utf8) else {
                return
            }
            
            self.inputValues[self.tokenKey] = code
            self.inputValues[self.tokenTypeKey] = self.tokenType
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

extension IdPCallback: GIDSignInDelegate {
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        self.inputValues[self.tokenKey] = user.authentication.idToken
        self.inputValues[self.tokenTypeKey] = self.tokenType
        self.completion?(user.authentication.idToken, self.tokenType, nil)
    }
}

extension IdPCallback: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    @available(iOS 13.0, *)
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}


public struct IdpClient {
    let provider: String
    let clientId: String
    let redirectUri: String
    let nonce: String?
    let scopes: [String]?
}
