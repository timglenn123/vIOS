//
//  AppDelegate.swift
//  VergeCurrencyWallet
//
//  Created by Swen van Zanten on 06-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Intents
import CoreData
import CoreStore
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sendRequest: SendTransaction?
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TorStatusIndicator.shared.initialize()
        NotificationManager.shared.initialize()
        ThemeManager.shared.initialize(withWindow: window ?? UIWindow())
        IQKeyboardManager.shared.enable = true
        
        registerAppforDetectLockState()
        setupListeners()

        // Start the tor client
        TorClient.shared.start {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.torClientStarted()
            }
        }

        do {
            CoreStore.defaultStack = DataStack(
                xcodeModelName: "CoreData",
                bundle: Bundle.main,
                migrationChain: [
                    "VergeiOS",
                    "VergeiOS 2"
                ]
            )

            try CoreStore.addStorageAndWait(
                SQLiteStore(fileName: "VergeiOS.sqlite", localStorageOptions: .allowSynchronousLightweightMigration)
            )
        } catch {
            print(error.localizedDescription)
        }

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AddressValidator().validate(string: url.absoluteString) { (valid, address, amount) in
            if !valid {
                return
            }
            
            let transaction = SendTransaction()
            transaction.address = address!
            transaction.amount = amount ?? 0.0
            
            self.sendRequest = transaction
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        WalletTicker.shared.stop()
        PriceTicker.shared.stop()
        TorClient.shared.resign()

        showPinUnlockViewController(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // Start the tor client
        TorClient.shared.start {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.torClientStarted()
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        // Stop price ticker.
        WalletTicker.shared.stop()
        PriceTicker.shared.stop()
        TorClient.shared.resign()
    }

    func torClientStarted() {
        // Start the price ticker.
        PriceTicker.shared.start()

        if !ApplicationManager.default.setup {
            return
        }

        // Start the wallet ticker.
        WalletTicker.shared.start()
        
        if #available(iOS 12.0, *) {
            self.donateSiriIntents()
        }
    }
    
    func registerAppforDetectLockState() {
        let callback: CFNotificationCallback = { center, observer, name, object, info in
            if TorClient.shared.isOperational {
                TorClient.shared.resign()
            }
        }

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            callback,
            "com.apple.springboard.lockstate" as CFString,
            nil,
            .deliverImmediately
        )
    }

    func showPinUnlockViewController(_ application: UIApplication) {
        if !ApplicationManager.default.setup {
            return
        }

        if var topController = application.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if let openedPinView = topController as? PinUnlockViewController {
                openedPinView.closeButtonPushed(self)
                
                return showPinUnlockViewController(application)
            }
            
            let vc = PinUnlockViewController.createFromStoryBoard()
            vc.fillPinFor = .wallet
            
            print("Show unlock view")
            topController.present(vc, animated: false, completion: nil)
        }
    }
    
    @available(iOS 12.0, *)
    func donateSiriIntents() {
        let priceIntent = VergePriceIntent()
        priceIntent.suggestedInvocationPhrase = "Verge price"
        
        let interaction = INInteraction(intent: priceIntent, response: nil)
        
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    NSLog("Interaction donation failed: %@", error)
                } else {
                    NSLog("Successfully donated interaction")
                }
            }
        }
    }
}
