//
//  FacebookAuthenticator.swift
//  BLZFirebaseAuthenticator
//
//  Created by Leonardo Passeri on 10/01/2020.
//

import UIKit
import RxSwift
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth

public enum FirebaseAuthenticationFacebookError: LocalizedError {
    case loginCancelled
    case loginError
    case missingEmailError
    case deniedEmailError
    case mergeAccountError
}

extension FirebaseAuthenticator {
    
    public func facebookLogin(view:UIViewController) -> Single<FirebaseAuthInfo> {

        self.currentFirebaseAuthFlowManager = FirebaseAuthFlowManager(
            onApplicationOpenUrlCallback: { (application, url, options) -> Bool in
                return ApplicationDelegate.shared.application(application, open: url, options: options)
        }, logOutCallback: {
            let login = LoginManager()
            login.logOut()
        })
        
        return Single<FirebaseAuthInfo>.create { (single) -> Disposable in
            let login = LoginManager()
            login.logIn(permissions: ["public_profile", "email"], from: view) { (result, error) in
                guard let result = result, error == nil else {
                    if let error = error {
                        print("Facebook Login Error: \(error.localizedDescription)")
                        single(.error(FirebaseAuthenticationFacebookError.loginError))
                    }
                    return
                }
                if result.isCancelled {
                    print("Facebook Login Cancelled")
                    single(.error(FirebaseAuthenticationFacebookError.loginCancelled))
                }
                else if false == (result.grantedPermissions).contains("email") {
                    print("Facebook Denied Email Permission")
                    single(.error(FirebaseAuthenticationFacebookError.deniedEmailError))
                } else {
                    GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
                        guard error == nil else {
                            if let error = error {
                                print("Facebook Get User Data Error: \(error.localizedDescription)")
                            }
                            single(.error(FirebaseAuthenticationError.remoteServerError))
                            return
                        }
                        guard let result = result as? [String:Any], let email = result["email"] as? String else {
                            print("Facebook Missing Email Error")
                            single(.error(FirebaseAuthenticationFacebookError.missingEmailError))
                            return
                        }
                        let displayName = result["name"] as? String ?? ""
                        print("Facebook Login Successful")
                        Auth.auth().fetchSignInMethods(forEmail: email, completion: { (previouslyUsedProviders, error) in
                            guard nil == error, let token = AccessToken.current?.tokenString else {
                                print("Firebase error while checking previous sign-in providers: \(error?.localizedDescription ?? "")")
                                single(.error(FirebaseAuthenticationError.remoteServerError))
                                return
                            }
                            let credential = FacebookAuthProvider.credential(withAccessToken: token)
                            Auth.auth().signIn(with: credential) { (authResult, error) in
                                guard let user = authResult?.user, error == nil else {
                                    if let error = error , let errorCode = AuthErrorCode(rawValue: error._code) {
                                        if errorCode == .accountExistsWithDifferentCredential {
                                            single(.error(FirebaseAuthenticationFacebookError.mergeAccountError))
                                            return
                                        }
                                        print("Firebase Facebook Login Error: \(error.localizedDescription)")
                                    }
                                    single(.error(FirebaseAuthenticationError.remoteServerError))
                                    return
                                }
                                let isFirstSignIn = (previouslyUsedProviders ?? []).count == 0
                                single(.success(FirebaseAuthInfo(identifier: user.uid, displayName: displayName, email: email, firstSocialAuth: isFirstSignIn)))
                            }
                        })
                    }
                }
            }
            return Disposables.create()
            }
    }
}
