//
//  WalletServiceProvider.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import Swinject
import CoreStore

class WalletServiceProvider: ServiceProvider {

    override func register() {
        self.registerWalletCredentials()
        self.registerWalletClient()
        self.registerTxTransponder()
        self.registerTransactionRepository()
        self.registerTransactionFactory()
        self.registerTransactionManager()
        self.registerWalletTicker()
        self.registerFiatRateTicker()
        self.registerAddressBookRepository()
        self.registerSweeperHelper()
        self.registerWalletManager()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bootServerMigration(notification:)),
            name: .didFinishTorStart,
            object: nil
        )
    }

    func registerWalletCredentials() {
        container.register(Credentials.self) { r in
            let appRepo = r.resolve(ApplicationRepository.self)!
            let mnemonic = appRepo.mnemonic ?? []
            let passphrase = appRepo.passphrase ?? ""

            return Credentials(mnemonic: mnemonic, passphrase: passphrase, network: .mainnetXVG)
        }.inObjectScope(.container)
    }

    func registerWalletClient() {
        container.register(WalletClient.self) { r in
            let appRepo = r.resolve(ApplicationRepository.self)!
            let credentials = r.resolve(Credentials.self)!
            let torClient = r.resolve(TorClient.self)!

            return WalletClient(appRepo: appRepo, credentials: credentials, torClient: torClient)
        }.inObjectScope(.container)

        container.register(WalletClientProtocol.self) { r in
            return r.resolve(WalletClient.self)!
        }
    }

    func registerTxTransponder() {
        container.register(TxTransponder.self) { r in
            TxTransponder(walletClient: r.resolve(WalletClient.self)!)
        }
    }

    func registerTransactionRepository() {
        container.register(TransactionRepository.self) { r in
            TransactionRepository(dataStack: r.resolve(DataStack.self)!)
        }
    }

    func registerTransactionFactory() {
        container.register(WalletTransactionFactory.self) { r in
            let fiatRateTracker = r.resolve(FiatRateTicker.self)!

            return WalletTransactionFactory(fiatRateTracker: fiatRateTracker)
        }
    }

    func registerTransactionManager() {
        container.register(TransactionManager.self) { r in
            let walletClient = r.resolve(WalletClient.self)!
            let transactionRepository = r.resolve(TransactionRepository.self)!

            return TransactionManager(walletClient: walletClient, transactionRepository: transactionRepository)
        }
    }

    func registerWalletTicker() {
        container.register(WalletTicker.self) { r in
            let walletClient = r.resolve(WalletClientProtocol.self)!
            let appRepo = r.resolve(ApplicationRepository.self)!
            let transactionManager = r.resolve(TransactionManager.self)!

            return WalletTicker(
                client: walletClient,
                applicationRepository: appRepo,
                transactionManager: transactionManager
            )
        }.inObjectScope(.container)
    }

    func registerFiatRateTicker() {
        container.register(FiatRateTicker.self) { r in
            let appRepo = r.resolve(ApplicationRepository.self)!
            let ratesClient = r.resolve(RatesClient.self)!

            return FiatRateTicker(applicationRepository: appRepo, statisicsClient: ratesClient)
        }.inObjectScope(.container)
    }

    func registerAddressBookRepository() {
        container.register(AddressBookRepository.self) { r in
            AddressBookRepository(dataStack: r.resolve(DataStack.self)!)
        }
    }

    func registerSweeperHelper() {
        container.register(SweeperHelperProtocol.self) { r in
            SweeperHelper(
                bitcoreNodeClient: r.resolve(BitcoreNodeClientProtocol.self)!,
                walletClient: r.resolve(WalletClientProtocol.self)!,
                transactionFactory: r.resolve(TransactionFactoryProtocol.self)!,
                transactionManager: r.resolve(TransactionManager.self)!
            )
        }
    }

    func registerWalletManager() {
        container.register(WalletManagerProtocol.self) { r in
            WalletManager(
                walletClient: r.resolve(WalletClientProtocol.self)!,
                walletTicker: r.resolve(WalletTicker.self)!,
                applicationRepository: r.resolve(ApplicationRepository.self)!
            )
        }.inObjectScope(.container)
    }

    @objc func bootServerMigration(notification: Notification) {
        let applicationRepository = self.container.resolve(ApplicationRepository.self)!

        // Check if the deprecated VWS endpoints are in the users memory.
        if applicationRepository.isWalletServiceUrlSet && !Constants.deprecatedBwsEndpoints.contains(
            applicationRepository.walletServiceUrl
        ) {
            return print("No deprecated VWS endpoints found.")
        }

        let walletClient = self.container.resolve(WalletClientProtocol.self)!
        let walletManager = self.container.resolve(WalletManagerProtocol.self)!

        // If so replace them by the replacement VWS endpoint.
        applicationRepository.walletServiceUrl = Constants.bwsEndpoint
        walletClient.resetServiceUrl(baseUrl: applicationRepository.walletServiceUrl)

        // If the wallet is setup we check on the server if there is a wallet present.
        if applicationRepository.setup {
            walletManager.joinWallet(createWallet: true) { error in
                if error != nil {
                    return print(error ?? "Unresolved error")
                }

                walletManager.synchronizeWallet { error in
                    print(error ?? "Unresolved error")
                }
            }
        }
    }
}
