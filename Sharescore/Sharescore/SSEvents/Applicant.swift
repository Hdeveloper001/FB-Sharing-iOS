//
//  Applicant.swift
//  Sharescore
//
//  Created by iOSpro on 22/06/2017.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import Foundation
import SwiftyJSON

class Applicant: NSObject{
    var id: String = ""
    var fb_userid : String = ""
    var username: String = ""
    var fb_profile_image: String = ""
    var postId: String = ""
    var postImageUrl: String = ""
    var fb_location : String = ""
    var sse_id : String = ""
    var caption : String = ""
    var fb_likescount : String = ""
    var rank : String = ""
    var sseName : String = ""
    var sseLogo : String = ""
    var sse_startDate : String = ""
    var sse_endDate : String = ""
    var sse_cycleDuration : String = ""
    
    func initUserData(){
        
        id = ""
        fb_userid = ""
        username = ""
        fb_profile_image = ""
        postId = ""
        postImageUrl = ""
        fb_location = ""
        sse_id = ""
        caption = ""
        fb_likescount = ""
        rank = ""
        sseName = ""
        sseLogo = ""
        
        sse_startDate = ""
        sse_endDate = ""
        sse_cycleDuration = ""
        
    }
    
    
    func initUserDataWithJSON(json: SwiftyJSON.JSON){
        
        id  = json["id"].stringValue
        fb_userid = json["fb_id"].stringValue
        username = json["username"].stringValue
        fb_profile_image = json["profile_picture"].stringValue
        postId = json["post_id"].stringValue
        postImageUrl = json["image"].stringValue
        fb_location = json["location"].stringValue
        sse_id = json["sse_id"].stringValue
        caption = json["caption"].stringValue
        fb_likescount = json["like_count"].stringValue
        rank = json["rank"].stringValue
        
        sseName = json["sse_name"].stringValue
        sseLogo = json["logo"].stringValue
        
        sse_startDate = json["sse_start_date"].stringValue
        sse_endDate = json["sse_end_date"].stringValue
        sse_cycleDuration = json["peak_duration"].stringValue
    }
    
    
    func initUserDataWithDictionary(value: NSDictionary?){
        if (value != nil){
            
            let n_id: Int = value?["id"] as! Int
            self.id = String(n_id)
            self.fb_userid = value?["fb_id"] as? String ?? ""
            self.username = value?["username"] as? String ?? ""
            self.fb_profile_image = value?["profile_picture"] as? String ?? ""
            if (self.fb_profile_image.contains("large")){
                self.fb_profile_image = self.fb_profile_image.replacingOccurrences(of: "large", with: "small")
            }
            self.postId = value?["post_id"] as? String ?? ""
            self.postImageUrl = value?["image"] as? String ?? ""
            self.fb_location = value?["location"] as? String ?? ""
            
            let n_sseid: Int = value?["sse_id"] as! Int
            self.sse_id = String(n_sseid)
            
            self.caption = value?["caption"] as? String ?? ""
            
            let n_likescount: Int = value?["like_count"] as! Int
            self.fb_likescount = String(n_likescount)
            
            let n_rank: Int = value?["rank"] as! Int
            self.rank = String(n_rank)
            
            self.sseName = value?["sse_name"] as? String ?? ""
            self.sseLogo = value?["logo"] as? String ?? ""
            
            self.sse_startDate = value?["sse_start_date"] as? String ?? ""
            self.sse_endDate = value?["sse_end_date"] as? String ?? ""
            
            let temp = value?["peak_duration"]
            if (temp != nil){
                let n_cycleduration = value?["peak_duration"] as! Int
                sse_cycleDuration = String(n_cycleduration)
            }
        }
    }
}
