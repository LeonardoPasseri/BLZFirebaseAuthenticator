//
//  UIViewController+HideKeyboard.swift
//  BLZFirebaseAuthenticator_Example
//
//  Created by Leonardo Passeri on 10/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func hideKeyboardWhenTappedAround(cancelTouchesInView:Bool = false) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = cancelTouchesInView
        view.addGestureRecognizer(tap)
    }
    
    @objc public func dismissKeyboard() {
        view.endEditing(true)
    }
}
