//
//  FirebaseAuthenticationError+Localization.swift
//  BLZFirebaseAuthenticator_Example
//
//  Created by Leonardo Passeri on 10/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import BLZFirebaseAuthenticator

extension FirebaseAuthenticationError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .getTokenError: return "Get Token Error"
        case .remoteServerError: return "Remote Server Error"
        case .userNotLoggedIn: return "User Not Logged In"
        }
    }
}

extension FirebaseAuthenticationFacebookError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .deniedEmailError: return "Denied Email Error"
        case .loginCancelled: return "Login Cancelled Error"
        case .loginError: return "Login error"
        case .missingEmailError: return "Missing Email error"
        case .mergeAccountError: return "Merging Account error"
        }
    }
}

extension FirebaseAuthenticationGoogleError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .loginCancelled: return "Login Cancelled Error"
        case .loginError: return "Login error"
        }
    }
}

extension FirebaseAuthenticationEmailError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emailAlreadyTakenError: return "Email Already Taken Error"
        case .invalidEmail: return "Invalid Email Error"
        case .userNotFoundError: return "User Not Found error"
        case .wrongPasswordError: return "Wrong Password error"
        }
    }
}
