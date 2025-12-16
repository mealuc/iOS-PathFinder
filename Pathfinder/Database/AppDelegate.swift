//
//  Connection.swift
//  Pathfinder
//
//  Created by EmreAluc on 3.02.2025.
//
import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil)
    -> Bool {
        FirebaseApp.configure()
        print("Firebase Configured")
        return true
    }
    
    func application (
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}

