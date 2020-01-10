//
//  SignUpViewController.swift
//  BLZFirebaseAuthenticator_Example
//
//  Created by Leonardo Passeri on 10/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import BLZFirebaseAuthenticator

class SignUpViewController: UIViewController {
    
    @IBOutlet private weak var displayNameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signUpButton.addTarget(self, action: #selector(self.signUpButtonPressed), for: .touchUpInside)
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Actions
    
    @objc private func signUpButtonPressed() {
        if let email = self.emailTextField.text, !email.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty,
            let displayName = self.displayNameTextField.text, !displayName.isEmpty {
            FirebaseAuthenticator.registerUser(email: email, password: password).subscribe(onSuccess: { () in
                self.showAlert(withMessage: "Sign-up successful! Check your email and verify your account!")
            }, onError: { (error) in
                self.handleAuthenticationError(withError: error)
            }).disposed(by: self.disposeBag)
        }
    }
}
