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

public enum FirebaseAuthenticationError: LocalizedError {
    case remoteServerError
    case userNotLoggedIn
    case getTokenError
}

public struct FirebaseAuthInfo {
    let identifier: String
    let displayName: String
    let email: String
    let firstSocialAuth: Bool
}

typealias OnApplicationOpenUrlCallback = ((UIApplication, URL, [UIApplication.OpenURLOptionsKey : Any]) -> Bool)
typealias LogOutCallback = (() -> ())

struct FirebaseAuthFlowManager {
    let onApplicationOpenUrlCallback: OnApplicationOpenUrlCallback
    let logOutCallback: LogOutCallback
}

public class FirebaseAuthenticator {
    
    public var firebaseAuthId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var currentFirebaseAuthFlowManager: FirebaseAuthFlowManager?
    
    public func setDisplayName(displayName: String) -> Single<Void> {
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
    
    public func getFirebaseAuthToken() -> Single<String> {
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
    
    public func logout() -> Single<Void> {
        do {
            try Auth.auth().signOut()
        } catch {
            // No error propagation. Forced logout anyway (don't know how to handle this gracefully otherwise)
            print("Error while signing out: \(error.localizedDescription)")
        }
        self.currentFirebaseAuthFlowManager?.logOutCallback()
        return Single.just(Void())
    }
    
    public func onApplication(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return self.currentFirebaseAuthFlowManager?.onApplicationOpenUrlCallback(application, url, options) ?? false
    }
}
