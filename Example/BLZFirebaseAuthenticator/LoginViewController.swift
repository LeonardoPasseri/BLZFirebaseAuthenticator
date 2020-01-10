//
//  LoginViewController.swift
//  BLZFirebaseAuthenticator
//
//  Created by Leonardo Passeri on 01/09/2020.
//  Copyright (c) 2020 Leonardo Passeri. All rights reserved.
//

import UIKit
import RxSwift
import BLZFirebaseAuthenticator

class LoginViewController: UIViewController {

    @IBOutlet private weak var emailSignUpButton: UIButton!
    @IBOutlet private weak var emailLoginButton: UIButton!
    @IBOutlet private weak var googleLoginButton: UIButton!
    @IBOutlet private weak var facebookLoginButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if EMAIL_LOGIN
        self.emailSignUpButton.addTarget(self, action: #selector(self.emailSignUpButtonPressed), for: .touchUpInside)
        self.emailLoginButton.addTarget(self, action: #selector(self.emailLoginButtonPressed), for: .touchUpInside)
        #else
        self.emailSignUpButton.isHidden = true
        self.emailLoginButton.isHidden = true
        #endif
        
        #if FACEBOOK_LOGIN
        self.facebookLoginButton.addTarget(self, action: #selector(self.facebookLoginButtonPressed), for: .touchUpInside)
        #else
        self.facebookLoginButton.isHidden = true
        #endif
        
        #if GOOGLE_LOGIN
        self.googleLoginButton.addTarget(self, action: #selector(self.googleLoginButtonPressed), for: .touchUpInside)
        #else
        self.googleLoginButton.isHidden = true
        #endif
    }
    
    // MARK: - Actions
    
    @objc private func emailSignUpButtonPressed() {
        self.performSegue(withIdentifier: "showSignUp", sender: nil)
    }
    
    @objc private func emailLoginButtonPressed() {
        self.performSegue(withIdentifier: "showEmailLogin", sender: nil)
    }
    
    @objc private func facebookLoginButtonPressed() {
        FirebaseAuthenticator.facebookLogin(view: self).subscribe(onSuccess: { (authInfo) in
            self.goToProfile(authInfo: authInfo)
        }, onError: { (error) in
            self.handleAuthenticationError(withError: error)
        }).disposed(by: self.disposeBag)
    }
    
    @objc private func googleLoginButtonPressed() {
        FirebaseAuthenticator.googleLogin(viewController: self).subscribe(onSuccess: { (authInfo) in
            self.goToProfile(authInfo: authInfo)
        }, onError: { (error) in
            self.handleAuthenticationError(withError: error)
        }).disposed(by: self.disposeBag)
    }
}

