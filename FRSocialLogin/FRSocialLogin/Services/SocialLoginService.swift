//
//  SocialLoginService.swift
//  FRSocialLogin
//
//  Created by James Go on 1/26/21.
//

import Foundation
import FRAuth

public typealias SocialLoginCallback = (_ result: String?, _ tokenType: String?, _ error:Error?) -> Void

class SocialLoginService: NSObject {
    var idpClient: IdpClient
    var presentingViewController: UIViewController?
    var tokenType: String = ""
    
    init(idpClient: IdpClient, viewController: UIViewController?) {
        self.idpClient = idpClient
        self.presentingViewController = viewController
    }
    
    func login(completion: @escaping SocialLoginCallback) {
        FRLog.e("SocialLoginService.login should be invoked through a dedicated identity provider's service.")
    }
}


extension SocialLoginService {
    static func createService(idpClient: IdpClient) -> SocialLoginService {
        
        if idpClient.provider.lowercased() == "facebook" {
            return FBLoginService(idpClient: idpClient, viewController: nil)
        }
        else if idpClient.provider.lowercased() == "apple" {
            return SIWAService(idpClient: idpClient, viewController: nil)
        }
        else {
            return GSIService(idpClient: idpClient, viewController: nil)
        }
    }
}
