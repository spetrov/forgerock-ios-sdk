// 
//  OathMechanism.swift
//  FRAuthenticator
//
//  Copyright (c) 2020 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


import Foundation

public class OathMechanism: Mechanism {
    
    //  MARK: - Properties
    
    /// Algorithm of OATH OTP
    var algorithm: String?
    /// Length of OATH Code
    public var digits: Int
    
    
    //  MARK: - Init
    
    /// Initializes OathMechanism with given data
    /// - Parameters:
    ///   - type: type of OATH
    ///   - issuer: issuer of OATH
    ///   - accountName: accountName of current OATH Mechanism
    ///   - secret: shared secret in string of OATH Mechanism
    ///   - algorithm: algorithm in string for OATH Mechanism
    ///   - digits: number of digits for TOTP code
    init(type: String, issuer: String, accountName: String, secret: String, algorithm: String? = nil, digits: Int? = 6) {
        
        self.algorithm = algorithm
        self.digits = digits ?? 6
        super.init(type: type, issuer: issuer, accountName: accountName, secret: secret)
    }
    
    
    /// Initializes OathMechanism with given data
    /// - Parameter mechanismUUID: Mechanism UUID
    /// - Parameter type: type of OATH
    /// - Parameter version: version of HOTPMechanism
    /// - Parameter issuer: issuer of OATH
    /// - Parameter secret: shared secret of OATH
    /// - Parameter accountName: accountName of OATH
    /// - Parameter algorithm: algorithm used for OATH
    /// - Parameter digits: length of OTP Credentials
    /// - Parameter timeAdded: Date timestamp for creation of Mechanism object 
    init?(mechanismUUID: String?, type: String?, version: Int?, issuer: String?, secret: String?, accountName: String?, algorithm: String?, digits: Int, timeAdded: Double) {
        self.algorithm = algorithm
        self.digits = digits
        super.init(mechanismUUID: mechanismUUID, type: type, version: version, issuer: issuer, secret: secret, accountName: accountName, timeAdded: timeAdded)
    }

    
    //  MARK: - NSCoder
    
    override public class var supportsSecureCoding: Bool { return true }
    
    
    override public func encode(with coder: NSCoder) {
        coder.encode(self.algorithm, forKey: "algorithm")
        coder.encode(self.digits, forKey: "digits")
        super.encode(with: coder)
    }
    

    public required convenience init?(coder: NSCoder) {
        let mechanismUUID = coder.decodeObject(of: NSString.self, forKey: "mechanismUUID") as String?
        let type = coder.decodeObject(of: NSString.self, forKey: "type") as String?
        let version = coder.decodeInteger(forKey: "version")
        let issuer = coder.decodeObject(of: NSString.self, forKey: "issuer") as String?
        let secret = coder.decodeObject(of: NSString.self, forKey: "secret") as String?
        let accountName = coder.decodeObject(of: NSString.self, forKey: "accountName") as String?
        let algorithm = coder.decodeObject(of: NSString.self, forKey: "algorithm") as String?
        let digits = coder.decodeInteger(forKey: "digits")
        let timeAdded = coder.decodeDouble(forKey: "timeAdded")
        self.init(mechanismUUID: mechanismUUID, type: type, version: version, issuer: issuer, secret: secret, accountName: accountName, algorithm: algorithm, digits: digits, timeAdded: timeAdded)
    }
}