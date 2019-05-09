//
//  FiatRateTickerTest.swift
//  VergeiOSTests
//
//  Created by Swen van Zanten on 05/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import XCTest
@testable import VergeiOS

class FiatRateTickerTest: XCTestCase {

    func testExample() {
        let appRepo = ApplicationRepositoryMock()
        let ratesClient = RatesClientMock()
        let ticker = FiatRateTicker(applicationRepository: appRepo, statisicsClient: ratesClient)

        ticker.start()
    }

}

class ApplicationRepositoryMock: ApplicationRepository {
    
    public var storedSetup: Bool = true
}

class RatesClientMock: RatesClient {
    init() {
        super.init(torClient: TorClient(applicationRepository: ApplicationRepositoryMock()))
    }

    var fiatRate: FiatRate?

    override func infoBy(currency: String, completion: @escaping (FiatRate?) -> Void) {
        completion(self.fiatRate)
    }
}
