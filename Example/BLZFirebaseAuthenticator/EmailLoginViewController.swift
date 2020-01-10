//
//  EmailLoginViewController.swift
//  BLZFirebaseAuthenticator_Example
//
//  Created by Leonardo Passeri on 10/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import BLZFirebaseAuthenticator

class EmailLoginViewController: UIViewController {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.addTarget(self, action: #selector(self.loginButtonPressed), for: .touchUpInside)
        self.forgotPasswordButton.addTarget(self, action: #selector(self.forgotPasswordButtonPressed), for: .touchUpInside)
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonPressed() {
        if let email = self.emailTextField.text, !email.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty {
            FirebaseAuthenticator.emailLogin(email: email, password: password).subscribe(onSuccess: { (authInfo) in
                self.goToProfile(authInfo: authInfo)
            }, onError: { (error) in
                self.handleAuthenticationError(withError: error)
            }).disposed(by: self.disposeBag)
        }
    }
    
    @objc private func forgotPasswordButtonPressed() {
        if let email = self.emailTextField.text, !email.isEmpty {
            FirebaseAuthenticator.forgotPassword(email: email).subscribe(onSuccess: { () in
                self.showAlert(withMessage: "Password reset! Check your email and change your password")
            }, onError: { (error) in
                self.handleAuthenticationError(withError: error)
            }).disposed(by: self.disposeBag)
        }
    }
}
