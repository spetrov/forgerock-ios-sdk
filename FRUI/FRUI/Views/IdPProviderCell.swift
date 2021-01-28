// 
//  IdPProviderCell.swift
//  FRUI
//
//  Copyright (c) 2020 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


import Foundation
import FRAuth

class IdPProviderCell: UITableViewCell, FRUICallbackTableViewCell {
    
    // MARK: - Properties
    public static let cellIdentifier = "IdPProviderCellId"
    public static let cellHeight: CGFloat = 50.0
    
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var iconImgView: UIImageView?
    var delegate: AuthStepProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.descriptionLabel?.textColor = UIColor.hexStringToUIColor(hex: "#757575")
    }
    
    func updateCellData(callback: Callback) {
        
    }
    
    func updateCellWithProvider(provider: IdentityProvider) {
        var providerName = provider.provider
        if let displayName = provider.uiConfig["buttonDisplayName"] {
            providerName = displayName
        }
        self.descriptionLabel?.text = "Sign in with \(providerName)"
    }
}
