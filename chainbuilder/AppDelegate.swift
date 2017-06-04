//
//  AppDelegate.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2016-05-31.
//  Copyright © 2016 Morrdusk. All rights reserved.
//

import UIKit
import LogKit
import Firebase
import GoogleMobileAds

struct GlobalSettings {
    #if DEVELOPMENT
        // DEVELOPMENT SETTINGS
        static let logPriorityLevel = LXPriorityLevel.all
        static let showAds = false
        static let demoMode = false // if set to true use a specific demo database
    #elseif DEMO
        // DEMO SETTINGS
        static let logPriorityLevel = LXPriorityLevel.all
        static let showAds = false
        static let demoMode = true // if set to true use a specific demo database
    #else
        // PRODUCTION SETTINGS
        static let logPriorityLevel = LXPriorityLevel.error
        static let showAds = true
        static let demoMode = false // if set to true use a specific demo database
    #endif
    
    /**
        Reads adMobApplicationID from the plist file so it can be set per environment.
    */
    static func adMobApplicationID() -> String {
        if let v = Bundle.main.object(forInfoDictionaryKey: "adMobApplicationID") {
            return v as! String
        }
        return ""
    }
    
    /**
        Reads adMobAdUnitID from the plist file so it can be set per environment.
    */
    static func adMobAdUnitID() -> String {
        if let v = Bundle.main.object(forInfoDictionaryKey: "adMobAdUnitID") {
            return v as! String
        }
        return ""
    }
}

let log = LXLogger(endpoints: [LXConsoleEndpoint(synchronous: true, minimumPriorityLevel: GlobalSettings.logPriorityLevel)])

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white

        let chainViewModel = ChainViewModel()
        chainViewModel.createDefaultChainsIfNonePresent()
        
        guard let chains = chainViewModel.chains() else {
            log.error("No chains! Quitting")
            return false
        }
        
        let container = CalendarContainerViewController()
        container.slotsViewModel = SlotsViewModel(chains: chains)
        
        self.window!.rootViewController = container
        
        self.window?.makeKeyAndVisible()

        if GlobalSettings.showAds {
            // For Admob - Use Firebase library to configure APIs
            FirebaseApp.configure()
            GADMobileAds.configure(withApplicationID: GlobalSettings.adMobApplicationID())
        }
        
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

}

