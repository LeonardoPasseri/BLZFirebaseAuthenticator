//
//  FirebaseAuthenticator+Email.swift
//  BLZFirebaseAuthenticator
//
//  Created by Leonardo Passeri on 10/01/2020.
//

import Foundation
import RxSwift
import FirebaseAuth

public enum FirebaseAuthenticationEmailError : Error {
    case emailAlreadyTakenError
    case userNotFoundError
    case wrongPasswordError
    case invalidEmail
}

extension FirebaseAuthenticator {
    
    public static func emailLogin(email: String, password: String) -> Single<FirebaseAuthInfo> {
        
        self.currentFirebaseAuthFlowManager = FirebaseAuthFlowManager(logOutCallback: {})
        
        return Single<FirebaseAuthInfo>.create { (single) -> Disposable in
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                guard let user = authResult?.user, error == nil else {
                    if let error = error , let errorCode = AuthErrorCode(rawValue: error._code) {
                        if errorCode == .userNotFound {
                            single(.error(FirebaseAuthenticationEmailError.userNotFoundError))
                            return
                        } else if errorCode == .wrongPassword {
                            single(.error(FirebaseAuthenticationEmailError.wrongPasswordError))
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
                single(.success(FirebaseAuthInfo(identifier: user.uid, displayName: displayName, email: email, firstSocialAuth: false)))
            }
            return Disposables.create()
        }
    }
    
    public static func registerUser(email: String, password: String) -> Single<Void> {
        return Single<Void>.create { (single) -> Disposable in
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                guard nil != authResult?.user && error == nil else {
                    if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                        if errorCode == .emailAlreadyInUse {
                            single(.error(FirebaseAuthenticationEmailError.emailAlreadyTakenError))
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
    
    public static func forgotPassword(email: String) -> Single<Void> {
        return Single<Void>.create { (single) -> Disposable in
            Auth.auth().useAppLanguage()
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                guard error == nil else {
                    if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                        if errorCode == .invalidRecipientEmail {
                            single(.error(FirebaseAuthenticationEmailError.invalidEmail))
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
}
