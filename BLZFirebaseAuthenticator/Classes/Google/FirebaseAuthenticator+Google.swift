//
//  FirebaseAuthenticator+Google.swift
//  BLZFirebaseAuthenticator
//
//  Created by Leonardo Passeri on 10/01/2020.
//

import UIKit
import RxSwift
import FirebaseAuth
import GoogleSignIn

public enum FirebaseAuthenticationGoogleError: LocalizedError {
    case loginCancelled
    case loginError
}

fileprivate var googleSignInDelegate: GoogleSignInDelegate?

fileprivate class GoogleSignInDelegate : NSObject, GIDSignInDelegate {

    private let single: ((SingleEvent<(credential: AuthCredential, firstName: String, lastName: String, email: String)>) -> ())

    init(single: @escaping ((SingleEvent<(credential: AuthCredential, firstName: String, lastName: String, email: String)>) -> ())) {
        self.single = single
    }

    // MARK: - GIDSignInDelegate

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {

        if let error = error {
            print("Google login error: \(error.localizedDescription)")
            if let errorCode = GIDSignInErrorCode(rawValue: error._code), errorCode == .canceled {
                self.single(.error(FirebaseAuthenticationGoogleError.loginCancelled))
            } else {
                self.single(.error(FirebaseAuthenticationGoogleError.loginError))
            }
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

extension FirebaseAuthenticator {
    
    public func googleLogin(uiDelegate: GIDSignInUIDelegate) -> Single<FirebaseAuthInfo> {

        self.currentFirebaseAuthFlowManager = FirebaseAuthFlowManager(
            onApplicationOpenUrlCallback: { (application, url, options) -> Bool in
                return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }, logOutCallback: {
            GIDSignIn.sharedInstance().signOut()
        })
        
        return Single<(credential: AuthCredential, firstName: String, lastName: String, email: String)>.create { (single) -> Disposable in

            GIDSignIn.sharedInstance().uiDelegate = uiDelegate

            let delegate = GoogleSignInDelegate(single:single)
            GIDSignIn.sharedInstance().delegate = delegate
            // This assignment is needed to ensure persistence of the delegate
            googleSignInDelegate = delegate
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
                            single(.success(FirebaseAuthInfo(identifier: user.uid, displayName: displayName, email: result.email, firstSocialAuth: isFirstSignIn)))
                        }
                    })
                    return Disposables.create()
                }
            }
    }
}
