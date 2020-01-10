//
//  UIViewController+Navigation.swift
//  BLZFirebaseAuthenticator_Example
//
//  Created by Leonardo Passeri on 10/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import BLZFirebaseAuthenticator

extension UIViewController {
    
    func goToProfile(authInfo: FirebaseAuthInfo) {
        if let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window
        {
            profileViewController.authInfo = authInfo
            window.rootViewController = profileViewController
        }
    }
    
    func logout() {
        if let loginViewController = self.storyboard?.instantiateInitialViewController(),
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window
        {
            window.rootViewController = loginViewController
        }
    }
}
