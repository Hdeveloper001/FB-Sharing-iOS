//
//  AppDelegate.swift
//  Sharescore
//
//  Created by iOSpro on 3/9/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import SwiftyJSON
import AVFoundation
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var campaingTitle : String = ""
    
    var fb_postID : String = ""
    var fb_likes : String = ""
    
    var device_token: String = ""
    var fb_email: String = ""
    var fb_id: String = ""
    var fb_avatar: String = ""
    var user_name: String = ""
    var fbname: String = ""
    var fbtokenstring = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Push Notification
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {  
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        initAppBadge()
//        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Show_Home_BadgeNumber), object: nil)
        return true
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // Persist it in your backend in case it's new
        devToken = deviceTokenString
        
        let defaults : UserDefaults = UserDefaults.standard
        defaults.set(devToken, forKey: kSSE_APN_Device_Token)
        
        if let fbToken = defaults.string(forKey: kSSE_User_FB_Token) {
            print(fbToken)
            appDelegate.fbtokenstring = fbToken
            appDelegate.fb_id = defaults.string(forKey: kSSE_User_FB_Id)!
            appDelegate.fb_avatar = defaults.string(forKey: kSSE_User_FB_Avatar)!
            appDelegate.fbname = defaults.string(forKey: kSSE_User_FB_Name)!

            if (appDelegate.user_name != "")
            {
                let parameters = ["fbname": appDelegate.fbname, "fbid": appDelegate.fb_id, "profile_picture": appDelegate.fb_avatar, "fbtoken": appDelegate.fbtokenstring, "device_token": devToken]
                Alamofire.request(kAPI_LoginCheck, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
                
//                let parameters = ["username": appDelegate.user_name,
//                                  "fbid": appDelegate.fb_id,
//                                  "access_token": appDelegate.device_token,
//                                  "device_token": devToken] as [String : Any]
//                
//                Alamofire.request(kAPI_RegisterCheck, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
                    
                    print(response)
                    switch response.result {
                        
                    case .success(_):
                        
                        let jsonObject = JSON(response.result.value!)
                        print(jsonObject["result"])
                        break
                    case .failure( _):
                        break
                    }
                }
            }
        }
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
        guard
            let aps = data[AnyHashable("aps")] as? NSDictionary,
            let alert = aps["alert"] as? NSDictionary,
            let _ = alert["body"] as? String,
            let _ = alert["title"] as? String,
            let content = aps["content"] as? String
            else {
                // handle any error here
                return
        }
        let dict = COMMON.convertToDictionary(text: content)
        
        let sseNotification : SSENotification = SSENotification()
        sseNotification.initSSENotification(dic: dict! as NSDictionary)
        myNotifications.insert(sseNotification, at: 0)
        notificationBadgeNumber = notificationBadgeNumber + 1
        PlayAudio()
        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Show_Home_BadgeNumber), object: nil)
//        myNotifications.append(sseNotification)
    }
    
    func initAppBadge(){
        if(UIApplication.shared.applicationIconBadgeNumber != 0){
            HasNewNotification = true
            let parameters = ["user_id": USER.id] as [String : Any]
            Alamofire.request(kAPI_ClearNotificationbadge, method: .post, parameters: parameters).responseJSON { (responseData) -> Void in
                
//                SVProgressHUD.popActivity()
                if((responseData.result.value) != nil) {
                    if (responseData.result.isSuccess){
                        
                    }
                }
//                self.refreshAllDatas()
            }
            PlayAudio()
        }
        notificationBadgeNumber = UIApplication.shared.applicationIconBadgeNumber
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
    
    func PlayAudio(){
        let fileUrl = Bundle.main.url(forResource: "SSNotification", withExtension: "wav")!
        player = AVPlayer(url: fileUrl)
        player?.play()
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil) { (_) in
//            if !AlarmPlaying {
//                player?.seek(to: kCMTimeZero)
//                player?.play()
//            }
//            else{
//                player?.pause()
//            }
//        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        initAppBadge()
        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Show_Home_BadgeNumber), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}



