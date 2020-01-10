//
//  UIViewController+Alert.swift
//  BLZFirebaseAuthenticator_Example
//
//  Created by Leonardo Passeri on 10/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import BLZFirebaseAuthenticator

extension UIViewController {
    public func handleAuthenticationError(withError error: Error) {
        self.showAlert(withMessage: error.localizedDescription)
    }
    
    public func showAlert(withMessage message: String) {
        let alertView = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "OK", style: .cancel)
        alertView.addAction(closeAction)
        self.present(alertView, animated: true, completion: nil)
    }
}
