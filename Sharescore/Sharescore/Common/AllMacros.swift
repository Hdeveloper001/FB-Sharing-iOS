//
//  AllMacros.swift
//  My-Mo
//
//  Created by iDeveloper on 10/11/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import MBProgressHUD

var devToken: String = ""


let SLIDE_MENU_STYLE = 2
// MainScreen Height&Width
let Main_Screen_Height = UIScreen.main.bounds.size.height
let Main_Screen_Width = UIScreen.main.bounds.size.width

let appDelegate = (UIApplication.shared.delegate! as! AppDelegate)
let COMMON = Common()
let IMAGEPROCESSING = ImageProcessing()

var sseList = [SSEvent]()
var myApplications = [Applicant]()
var myNotifications = [SSENotification]()

var notificationBadgeNumber = 0;
var player:AVPlayer? = nil
var AlarmPlaying = true

var USER = User()
var CURRENT_SSE = SSEvent()

let prefs = UserDefaults.standard

//Tabbar Button Width
let button_width = 24

//let mainframe = (UIScreen.main.applicationFrame)
let mainframe = UIScreen.main.bounds
let IS_IPAD = (UI_USER_INTERFACE_IDIOM() == .pad)
let IS_IPHONE = (UI_USER_INTERFACE_IDIOM() == .phone)
let IS_RETINA = (UIScreen.main.scale >= 2.0)
let SCREEN_WIDTH = (UIScreen.main.bounds.size.width)
let SCREEN_HEIGHT = (UIScreen.main.bounds.size.height)
let SCREEN_MAX_LENGTH = (max(SCREEN_WIDTH, SCREEN_HEIGHT))
let SCREEN_MIN_LENGTH = (min(SCREEN_WIDTH, SCREEN_HEIGHT))
let IS_IPHONE_4_OR_LESS = (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
let IS_IPHONE_5 = (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
let IS_IPHONE_6 = (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
let IS_IPHONE_6PLUS = (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
let IS_IPAD_1 = (IS_IPAD && SCREEN_MAX_LENGTH == 1024.0)
let IS_IPAD_2 = (IS_IPAD && SCREEN_MAX_LENGTH == 1366.0)

var HasLogged = false
var HasNewNotification = false

//Alert
let kAppName = "Sharescore"
let kOkButton = "Ok"

let kLoginRequest = "Sorry unable to login Please try Later."
let kRegisterRequest = "Sorry unable to register user"
let kEnterUserName = "Please Enter User Name"

let kNoti_Show_Home_BadgeNumber = "show_Home_BadgeNumber"
let kNoti_Hide_Home_BadgeNumber = "hide_Home_BadgeNumber"

let kSSE_User_FB_Name = "sseFBname"
let kSSE_User_FB_Token = "sseFBtoken"
let kSSE_User_FB_Id = "sseFBid"
let kSSE_User_FB_Avatar = "sseFBavatar"
let kSSE_User_Name = "sseUsername"
let kSSE_User_Device_Token = "sseDeviceToken"
let kSSE_APN_Device_Token = "APNDeviceToken"

