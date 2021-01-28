//
//  GSIService.swift
//  FRSocialLogin
//
//  Created by James Go on 1/26/21.
//

import Foundation
import GoogleSignIn

class GSIService: SocialLoginService {
    
    override func login(completion: @escaping SocialLoginCallback) {
        
        if let vc = IdPCallback.getCurrentViewController() {
            GIDSignIn.sharedInstance()?.presentingViewController = vc
        }
        GIDSignIn.sharedInstance()?.clientID = self.idpClient.clientId
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
}


extension GSIService: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
