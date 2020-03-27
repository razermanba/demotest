//
//  AppDelegate.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/17/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import Foundation
import Fabric
import UIKit
import Firebase
import ObjectMapper
import Crashlytics
import UserNotifications
import JGProgressHUD


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let hud = JGProgressHUD(style: .dark)
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions,
                                                                    completionHandler: { (bool, err) in
                                                                        
            })
            
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        Messaging.messaging().isAutoInitEnabled = true
        
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        
        
        Fabric.with([Crashlytics.self])
        
        Fabric.sharedSDK().debug = true
        
        
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SocketIOManager.sharedInstance.socketDisconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        print(UserDefaults.standard.value(forKey: "room") as Any)
        if UserDefaults.standard.value(forKey: "room") != nil {
            SocketIOManager.sharedInstance.socketConnect()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let navigation: UINavigationController = storyboard.instantiateViewController(withIdentifier: "chatNavigationStoryboard") as! UINavigationController
        let chatVC  = (storyboard.instantiateViewController(withIdentifier: "ChatStoryBoardId") as! BasicExampleViewController)
        
        if UserDefaults.standard.value(forKey: "token") as? String != nil {
            guard !response.notification.request.content.userInfo.isEmpty else {
                return
            }
            
            if response.notification.request.content.userInfo["room_id"] as? String != nil{
                let roomID = response.notification.request.content.userInfo["room_id"] as? String
                UserDefaults.standard.set(roomID ?? "", forKey: "room")
                SocketIOManager.sharedInstance.socketConnect()
                
                navigation.pushViewController(chatVC, animated: true)
                self.window?.rootViewController = navigation
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func showLoading(){
        hud.textLabel.text = "Loading"
        hud.show(in: self.window!)
    }
    
    func dismissLoading(){
        hud.dismiss(afterDelay: 0.0)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }
}

