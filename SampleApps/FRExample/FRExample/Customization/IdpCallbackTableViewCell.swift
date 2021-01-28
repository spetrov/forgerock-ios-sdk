// 
//  IdpCallbackTableViewCell.swift
//  FRExample
//
//  Copyright (c) 2021 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


import UIKit
import FRAuth
import FRUI
import FRSocialLogin

class IdpCallbackTableViewCell: UITableViewCell, FRUICallbackTableViewCell {
    
    func updateCellData(callback: Callback) {
            
        if let social = callback as? IdPCallback {
            
            social.performLogin { (token, tokenType, error) in
                FRLog.w("Token: \(token ?? "") || Token Type: \(tokenType ?? "") || Error: \(error?.localizedDescription ?? "")")
                if let _ = token {
                    self.delegate?.submitNode()
                }
            }
        }
    }
    
    
    static var cellIdentifier: String = "IdpCallbackTableViewCellId"
    static var cellHeight: CGFloat = 10.0
    
    var delegate: AuthStepProtocol?
    var callback: NameCallback?
    
    func shouldSupport() -> Bool {
        return true
    }
}
