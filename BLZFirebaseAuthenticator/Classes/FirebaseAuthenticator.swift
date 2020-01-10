//
//  FirebaseAuthenticator.swift
//  FourBooks
//
//  Created by Leonardo Passeri on 05/11/2018.
//  Copyright © 2018 4Books. All rights reserved.
//

import UIKit
import RxSwift
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import GoogleSignIn

enum FirebaseAuthenticationError: LocalizedError {
    case loginCancelled
    case facebookLoginError
    case facebookMissingEmailError
    case facebookDeniedEmailError
    case mergeAccountError
    case googleLoginError
    case emailAlreadyTakenError
    case userNotFoundError
    case wrongPasswordError
    case invalidEmail
    case remoteServerError
    case userNotLoggedIn
    case getTokenError
}

struct FirebaseAuthInfo {
    let sharedAuthId: String
    let displayName: String
    let email: String
    let firstSocialAuth: Bool
}

class GoogleSignInDelegate : NSObject, GIDSignInDelegate {
    
    private let single: ((SingleEvent<(credential: AuthCredential, firstName: String, lastName: String, email: String)>) -> ())
    
    init(single: @escaping ((SingleEvent<(credential: AuthCredential, firstName: String, lastName: String, email: String)>) -> ())) {
        self.single = single
    }
    
    // MARK: - GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print("Google login error: \(error.localizedDescription)")
            self.single(.error(FirebaseAuthenticationError.googleLoginError))
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        var firstName = signIn.currentUser.profile.givenName ?? ""
        let lastName = signIn.currentUser.profile.familyName ?? ""
        
        if firstName.isEmpty && lastName.isEmpty {
            firstName = signIn.currentUser.profile.name ?? ""
        }
        
        self.single(.success((credential: credential,
                              firstName: firstName,
                              lastName: lastName,
                              email: signIn.currentUser.profile.email)))
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

class FirebaseAuthenticator {
    
    private var googleSignInDelegate: GoogleSignInDelegate?
    
    var firebaseAuthId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    func facebookLogin(view:UIViewController) -> Single<FirebaseAuthInfo> {

        return Single<FirebaseAuthInfo>.create { (single) -> Disposable in
            let login = LoginManager()
            login.logIn(permissions: ["public_profile", "email"], from: view) { (result, error) in
                guard let result = result, error == nil else {
                    if let error = error {
                        print("Facebook Login Error: \(error.localizedDescription)")
                        single(.error(FirebaseAuthenticationError.facebookLoginError))
                    }
                    return
                }
                if result.isCancelled {
                    print("Facebook Login Cancelled")
                    single(.error(FirebaseAuthenticationError.loginCancelled))
                }
                else if false == (result.grantedPermissions).contains("email") {
                    print("Facebook Denied Email Permission")
                    single(.error(FirebaseAuthenticationError.facebookDeniedEmailError))
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
                            single(.error(FirebaseAuthenticationError.facebookMissingEmailError))
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
                                            single(.error(FirebaseAuthenticationError.mergeAccountError))
                                            return
                                        }
                                        print("Firebase Facebook Login Error: \(error.localizedDescription)")
                                    }
                                    single(.error(FirebaseAuthenticationError.remoteServerError))
                                    return
                                }
                                let isFirstSignIn = (previouslyUsedProviders ?? []).count == 0
                                single(.success(FirebaseAuthInfo(sharedAuthId: user.uid, displayName: displayName, email: email, firstSocialAuth: isFirstSignIn)))
                            }
                        })
                    }
                }
            }
            return Disposables.create()
            }
    }
    
    func googleLogin(uiDelegate: GIDSignInUIDelegate) -> Single<FirebaseAuthInfo> {
        
        return Single<(credential: AuthCredential, firstName: String, lastName: String, email: String)>.create { (single) -> Disposable in
            
            GIDSignIn.sharedInstance().uiDelegate = uiDelegate
            
            let delegate = GoogleSignInDelegate(single:single)
            GIDSignIn.sharedInstance().delegate = delegate
            // This assignment is needed to ensure persistence of the delegate
            self.googleSignInDelegate = delegate
            GIDSignIn.sharedInstance().signIn()
            
            return Disposables.create()
            }.flatMap { (result) -> Single<FirebaseAuthInfo> in
                return Single<FirebaseAuthInfo>.create { (single) -> Disposable in
                    Auth.auth().fetchSignInMethods(forEmail: result.email, completion: { (previouslyUsedProviders, error) in
                        guard nil == error else {
                            print("Firebase error while checking previous sign-in providers: \(error?.localizedDescription ?? "")")
                            single(.error(FirebaseAuthenticationError.remoteServerError))
                            return
                        }
                        Auth.auth().signIn(with: result.credential) { (authResult, error) in
                            guard let user = authResult?.user, error == nil else {
                                if let error = error {
                                    print("Firebase Google Login Error: \(error.localizedDescription)")
                                }
                                single(.error(FirebaseAuthenticationError.remoteServerError))
                                return
                            }
                            
                            let displayName = "\(result.firstName) \(result.lastName)"
                            
                            print("Google Login Successful")
                            let isFirstSignIn = (previouslyUsedProviders ?? []).count == 0
                            single(.success(FirebaseAuthInfo(sharedAuthId: user.uid, displayName: displayName, email: result.email, firstSocialAuth: isFirstSignIn)))
                        }
                    })
                    return Disposables.create()
                }
            }
    }
    
    func customLogin(email: String, password: String) -> Single<FirebaseAuthInfo> {
        return Single<FirebaseAuthInfo>.create { (single) -> Disposable in
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                guard let user = authResult?.user, error == nil else {
                    if let error = error , let errorCode = AuthErrorCode(rawValue: error._code) {
                        if errorCode == .userNotFound {
                            single(.error(FirebaseAuthenticationError.userNotFoundError))
                            return
                        } else if errorCode == .wrongPassword {
                            single(.error(FirebaseAuthenticationError.wrongPasswordError))
                            return
                        }
                        print("Firebase Custom Login Error: \(error.localizedDescription)")
                    }
                    single(.error(FirebaseAuthenticationError.remoteServerError))
                    return
                }
                // User is signed in
                let displayName = user.displayName ?? ""
                
                print("Login Custom Successful")
                single(.success(FirebaseAuthInfo(sharedAuthId: user.uid, displayName: displayName, email: email, firstSocialAuth: false)))
            }
            return Disposables.create()
        }
    }
    
    func registerUser(email: String, password: String) -> Single<Void> {
        return Single<Void>.create { (single) -> Disposable in
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                guard nil != authResult?.user && error == nil else {
                    if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                        if errorCode == .emailAlreadyInUse {
                            single(.error(FirebaseAuthenticationError.emailAlreadyTakenError))
                            return
                        }
                        print("Firebase Create User Error: \(error.localizedDescription)")
                    }
                    single(.error(FirebaseAuthenticationError.remoteServerError))
                    return
                }
                
                print("Custom Registration Successful")
                single(.success(Void()))
            }
            return Disposables.create()
            }
    }
    
    func forgotPassword(email: String) -> Single<Void> {
        return Single<Void>.create { (single) -> Disposable in
            Auth.auth().useAppLanguage()
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                guard error == nil else {
                    if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                        if errorCode == .invalidRecipientEmail {
                            single(.error(FirebaseAuthenticationError.emailAlreadyTakenError))
                            return
                        }
                        print("Firebase Create User Error: \(error.localizedDescription)")
                    }
                    single(.error(FirebaseAuthenticationError.remoteServerError))
                    return
                }
                
                print("Forgot password Successful")
                single(.success(Void()))
            }
            return Disposables.create()
        }
    }
    
    func setDisplayName(displayName: String) -> Single<Void> {
        return Single<Void>.create { (single) -> Disposable in
            guard let userCurrent = Auth.auth().currentUser else {
                print("Get Token User Error: Missing authenticated user")
                single(.error(FirebaseAuthenticationError.userNotLoggedIn))
                return Disposables.create()
            }
            
            let changeRequest = userCurrent.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges(completion: { (error) in
                guard error == nil else {
                    if let error = error {
                        print("Get Token User Error: \(error.localizedDescription)")
                    }
                    single(.error(FirebaseAuthenticationError.userNotLoggedIn))
                    return
                }
                single(.success(Void()))
            })
            return Disposables.create()
        }
    }
    
    func getSharedAuthToken() -> Single<String> {
        return Single<String>.create { (single) -> Disposable in
            guard let userCurrent = Auth.auth().currentUser else {
                print("Get Token User Error: Missing authenticated user")
                single(.error(FirebaseAuthenticationError.userNotLoggedIn))
                return Disposables.create()
            }
            
            userCurrent.getIDToken(completion: { (firebaseToken, error) in
                guard let firebaseToken = firebaseToken, error == nil else {
                    if let error = error {
                        print("Get Token User Error: \(error.localizedDescription)")
                    }
                    single(.error(FirebaseAuthenticationError.userNotLoggedIn))
                    return
                }
                single(.success(firebaseToken))
            })
            return Disposables.create()
        }
    }
    
    func logout() -> Single<Void> {
        do {
            try Auth.auth().signOut()
        } catch {
            // No error propagation. Forced logout anyway (don't know how to handle this gracefully otherwise)
            print("Error while signing out: \(error.localizedDescription)")
        }
        GIDSignIn.sharedInstance().signOut()
        let login = LoginManager()
        login.logOut()
        return Single.just(Void())
    }
    
    func onApplication(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        var handled = false
        if ApplicationDelegate.shared.application(application, open: url, options: options) {
            handled = true
        }
        if GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:]) {
            handled = true
        }
        return handled
    }
}
