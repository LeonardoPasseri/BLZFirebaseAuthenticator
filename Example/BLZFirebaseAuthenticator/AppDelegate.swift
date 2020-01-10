//
//  AppDelegate.swift
//  BLZFirebaseAuthenticator
//
//  Created by Leonardo Passeri on 01/09/2020.
//  Copyright (c) 2020 Leonardo Passeri. All rights reserved.
//

import UIKit
import Firebase
#if FACEBOOK_LOGIN
import FBSDKCoreKit
#endif
#if GOOGLE_LOGIN
import GoogleSignIn
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        #if FACEBOOK_LOGIN
        // Facebook Init
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        #endif
        
        #if GOOGLE_LOGIN
        // Google Sign-In
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        #endif
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = false
        #if FACEBOOK_LOGIN
        handled = handled || ApplicationDelegate.shared.application(app, open: url, options: options)
        #endif
        #if GOOGLE_LOGIN
        handled = handled || GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        #endif
        return handled
    }
}

