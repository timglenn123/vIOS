//
// Created by Swen van Zanten on 25/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func createDeleteContactAlert(handler: ((UIAlertAction) -> Void)?) -> UIAlertController{
        let alert = UIAlertController(
            title: "Remove contact",
            message: "Are you sure you want to remove the contact?",
            preferredStyle: .alert
        )

        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: handler)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(delete)

        return alert
    }
    
    static func createInvalidContactAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "Invalid contact data",
            message: "Please provide a valid name and XVG address",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        
        return alert
    }

    static func createDeleteTransactionAlert(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(
            title: "Remove transaction",
            message: "Are you sure you want to remove this transaction?",
            preferredStyle: .alert
        )

        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: handler)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(delete)

        return alert
    }

    static func createAddressGapReachedAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "Cannot create address",
            message: "The maximum of inactive addresses have been reached. " +
                "Use one of the already generated addresses to create a new one.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))

        return alert
    }
}
