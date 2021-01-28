//
//  FacebookLoginService.swift
//  FRSocialLogin
//
//  Created by James Go on 1/26/21.
//

import Foundation
import FRAuth
import FacebookLogin

class FBLoginService: SocialLoginService {
    
    override func login(completion: @escaping SocialLoginCallback) {
        self.tokenType = "access_token"
        let fbManager = LoginManager()
        var fbPermissions: Set<Permission> = []
        for scope in idpClient.scopes ?? [] {
            let fbPermission = Permission(stringLiteral: scope)
            fbPermissions.insert(fbPermission)
        }
        
        let scopes = self.idpClient.scopes ?? []
        fbManager.logIn(permissions: scopes, from: self.presentingViewController) { (result, error) in
            FRLog.w("result: \(result)")
            FRLog.w("error: \(error?.localizedDescription)")
            completion(result?.token?.tokenString, self.tokenType, error)
        }
    }
}
