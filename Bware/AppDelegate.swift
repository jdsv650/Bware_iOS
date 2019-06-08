//
//  AppDelegate.swift
//  Bware
//
//  Created by James on 7/3/15.
//  Copyright (c) 2015 James. All rights reserved.
//

import UIKit
import GoogleMaps
import Flurry_iOS_SDK
import Google
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        window?.layer.backgroundColor = UIColor.orange.cgColor
        window?.tintColor = UIColor.orange
        UITextField.appearance().tintColor = UIColor.gray
        
        // Override point for customization after application launch.
        // Read our API keys in
        var isAPIkeyAvailable = false
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            if let dictionary = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                if let gmsAPIKey = dictionary["GoogleMapsAPIKey"] as? String
                {
                    GMSServices.provideAPIKey(gmsAPIKey)
                    isAPIkeyAvailable = true
                }
                
                if let flurryAPIKey = dictionary["FlurryAPIKey"] as? String
                {
                    Flurry.startSession(flurryAPIKey)
                }
                
            }
        }
        
        if isAPIkeyAvailable == false
        {
            print("Error fetching API key")
        }
 
        // Initialize Google sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        if configureError == nil
        {
            print("Error configuring Google services: \(String(describing:configureError))")
        }
 
        let defaults = UserDefaults.standard
        let access_token :String? = defaults.object(forKey: "access_token") as? String
        
        defaults.synchronize()
        
        if access_token != nil
        {
            print("access token exists launch")
            // bypass login flow -- token exists
            
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainController") as! UINavigationController
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
    
        let defaults = UserDefaults.standard
        let access_token :String? = defaults.object(forKey: "access_token") as? String
       // var expires  = defaults.objectForKey(".expires") as? String
    
        defaults.synchronize()
        
        if access_token == nil
        {
            print("access token not found - go to login flow")
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        }

    }
    
    @objc func dateformatterDateString(dateString: String) -> Date?
    {
        let dateFormatter: DateFormatter = DateFormatter()
       // dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.date(from: dateString)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplication.OpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }


}

