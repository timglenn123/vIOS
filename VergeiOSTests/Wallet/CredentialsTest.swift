//
//  CredentialsTest.swift
//  VergeiOSTests
//
//  Created by Swen van Zanten on 05/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import XCTest
@testable import VergeiOS

class CredentialsTest: XCTestCase {

    func testEmptyCredentials() {
        let credentials = Credentials(mnemonic: [], passphrase: "")

        XCTAssertEqual(credentials.privateKey.extended(), "TDt9EWvD5T5T44hAbJfjQZ2wQhPAx6nvNC99ygaBsHC9Epxv64Q97bii8pdYLHN5rDrKDuZLCHMoXiBGLPykLjV7eRQUVhU6Zi9sxQ6AjgTHx7W")
    }
    
    func testSetCredentials() {
        let mnemonic = [
            "januari",
            "februari",
            "march",
            "april",
            "may",
            "june",
            "july",
            "august",
            "september",
            "october",
            "november",
            "december"
        ]
        let credentials = Credentials(mnemonic: mnemonic, passphrase: "myPhrase123")
        
        XCTAssertEqual(credentials.privateKey.extended(), "TDt9EWvD5T5T44hAaTNgPCuwuVieU8VyPVKtqDsJcYeVKzC9mmhnfQ3Gtz6sS8JCWAwmkmeiwGGTfVju7KhLSSYXGTm1Zjb8N4FfaLjkMgW1ViN")
        XCTAssertEqual(credentials.bip44PrivateKey.extended(), "TDt9Ed9TVScfKCxnYcp65jVrjGR7Vkn4n3xkDxYNH51d7EGgQVdbrWMujehQ4KXBs2WUvRRf4z35KtdEu94CKPiS5FaUQw6CEr8WmWHLqZJYYBg")
        XCTAssertEqual(credentials.publicKey.extended(), "ToEA6m4Ax6Fh8J7gP6aRJtYQaReHLg4ddcNy9HcmJmmUm4zeWpeFZQBWfqP27TqMH9yKddpxEXpNBaK82Z3PvZxj8Cu6k5MGaFaCxdKZPS2LVeo")
        XCTAssertEqual(credentials.requestPrivateKey.extended(), "TDt9EbwxTCenz5KbWo8a9F53LZu85ScaKUy8qLRbMmouAnJQx2FwZGk3kDQNg7zGTTgwDMfvUHZhM2A5YUrU51isT5zh4SCEAWBzZcNo4t2Q71N")
        XCTAssertEqual(credentials.walletPrivateKey.extended(), "TDt9EZ4TAhbWQtQcbFE9C7DRXVSrzudCYCeDrWkkJKF1BTe5S2equs5pgRciJ4ZvJEt9uHoj1FQ5R7RrgBCV7ySREg9E9RyFxjkbbk48NuMroE8")
        XCTAssertEqual(credentials.sharedEncryptingKey, "VkUm9mZxlXIL/7ApL+9i+A==")
        XCTAssertEqual(credentials.personalEncryptingKey, "b0WwpLY1GXk2Tudktz0uUw==")
    }

}
