//
//  User.swift
//  Sharescore
//
//  Created by iOSpro on 23/4/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import Foundation
import SwiftyJSON


class User: NSObject{
    var id: String = ""
    var user_name: String = ""
    var email: String = ""
    var fb_id: String = ""
    var fb_avatar: String = ""
    var fb_token : String = ""
    var deviceToken = ""
    
    func initUserData(){
        id = ""
        user_name = ""
        fb_id = ""
        fb_avatar = ""
        email = ""
        fb_token = ""
        deviceToken = ""
    }    
    
    
    func initUserDataWithJSON(json: SwiftyJSON.JSON){
        id  = json["id"].stringValue
        user_name = json["username"].stringValue
        email = json["email"].stringValue
        fb_id = json["fbid"].stringValue
        fb_avatar = json["profile_picture"].stringValue
        deviceToken = json["access_token"].stringValue
    }
    
    
    func initUserDataWithDictionary(value: NSDictionary?){
        if (value != nil){
            self.id = value?["id"] as? String ?? ""
            self.email = value?["email"] as? String ?? ""
            self.user_name = value?["username"] as? String ?? ""
            self.fb_id = value?["fbid"] as? String ?? ""
            self.fb_avatar = value?["profile_picture"] as? String ?? ""
            self.deviceToken = value?["access_token"] as? String ?? ""
        }
    }
    
}
