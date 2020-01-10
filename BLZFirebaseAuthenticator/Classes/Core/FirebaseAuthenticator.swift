//
//  FirebaseAuthenticator.swift
//  FourBooks
//
//  Created by Leonardo Passeri on 05/11/2018.
//  Copyright © 2018 4Books. All rights reserved.
//

import UIKit
import RxSwift
import FirebaseAuth

public enum FirebaseAuthenticationError : Error {
    case remoteServerError
    case userNotLoggedIn
    case getTokenError
}

public struct FirebaseAuthInfo {
    public let identifier: String
    public let displayName: String
    public let email: String
    public let firstSocialAuth: Bool
}

typealias OnApplicationOpenUrlCallback = ((UIApplication, URL, [UIApplication.OpenURLOptionsKey : Any]) -> Bool)
typealias LogOutCallback = (() -> ())

struct FirebaseAuthFlowManager {
    let logOutCallback: LogOutCallback
}

public class FirebaseAuthenticator {
    
    public init() {}
    
    public class var firebaseAuthId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    static var currentFirebaseAuthFlowManager: FirebaseAuthFlowManager?
    
    public static func setDisplayName(displayName: String) -> Single<Void> {
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
    
    public static func getFirebaseAuthToken() -> Single<String> {
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
    
    public static func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            // No error propagation. Forced logout anyway (don't know how to handle this gracefully otherwise)
            print("Error while signing out: \(error.localizedDescription)")
        }
        self.currentFirebaseAuthFlowManager?.logOutCallback()
    }
}
