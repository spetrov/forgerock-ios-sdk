//
//  SelectIdPCallback.swift
//  FRSocialLogin
//
//  Copyright (c) 2020 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


import Foundation
import FRAuth

public class SelectIdPCallback: SingleValueCallback {
    
    public var providers: [IdentityProvider]
    
    required init(json: [String : Any]) throws {
        
        var thisProvider: [IdentityProvider] = []
        if let outputs = json["output"] as? [[String: Any]] {
            for output in outputs {
                if let outputName = output["name"] as? String, outputName == "providers", let providers = output["value"] as? [[String: Any]] {
                    for provider in providers {
                        
                        guard let providerId = provider["provider"] as? String else {
                            throw AuthError.invalidCallbackResponse("Missing providerName")
                        }
                        
                        let uiConfig = provider["uiConfig"] as? [String: String]
                        thisProvider.append(IdentityProvider(provider: providerId, uiConfig: uiConfig))
                    }
                }
            }
        }
        self.providers = thisProvider
        try super.init(json: json)
    }
    
    public func getSocialProviderCount() -> Int {
        var counter = 0
        for provider in self.providers {
            if provider.provider != "localAuthentication" {
                counter = counter + 1
            }
        }
        return counter
    }
}


public class IdentityProvider {
    public let provider: String
    public let uiConfig: [String: String]
    
    init(provider: String, uiConfig: [String: String]?) {
        self.provider = provider
        self.uiConfig = uiConfig ?? [:]
    }
}
