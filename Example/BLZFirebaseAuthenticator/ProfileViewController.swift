//
//  ProfileViewController.swift
//  BLZFirebaseAuthenticator_Example
//
//  Created by Leonardo Passeri on 10/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import BLZFirebaseAuthenticator

class ProfileViewController: UIViewController {
    
    public var authInfo: FirebaseAuthInfo?
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var firebaseIdentifierLabel: UILabel!
    @IBOutlet private weak var isFirstSocialLoginLabel: UILabel!
    @IBOutlet private weak var firebaseTokenLabel: UILabel!
    @IBOutlet private weak var logoutButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let authInfo = self.authInfo {
            //TODO: add avatar image
            self.avatarImageView.isHidden = true
            self.emailLabel.text = "Email: \(authInfo.email)"
            self.displayNameLabel.text = "Display Name: \(authInfo.displayName)"
            self.firebaseIdentifierLabel.text = "Identifier: \(authInfo.identifier)"
            self.isFirstSocialLoginLabel.text = "First Social Login: \(authInfo.firstSocialAuth ? "YES" : "NO")"
            self.firebaseTokenLabel.text = "Token: \(FirebaseAuthenticator.getFirebaseAuthToken())"
        }
        
        FirebaseAuthenticator.getFirebaseAuthToken().subscribe(onSuccess: { (token) in
            self.firebaseTokenLabel.text = "Token: \(token)"
        }, onError: { (error) in
            self.firebaseTokenLabel.text = "Token: Error!"
        }).disposed(by: self.disposeBag)
        
        self.logoutButton.addTarget(self, action: #selector(self.logoutButtonPressed), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func logoutButtonPressed() {
        FirebaseAuthenticator.logout()
        self.logout()
    }
}
