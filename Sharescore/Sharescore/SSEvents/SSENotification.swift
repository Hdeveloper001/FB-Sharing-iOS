//
//  Notification.swift
//  Sharescore
//
//  Created by iOSpro on 11/8/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import Foundation

class SSENotification: NSObject{
    
    var sseID : String = ""
    var sseName : String = ""
    var imgUrl : String = ""
    var numOfPeak : String = ""
    var numOfWinners : String = ""
    var current_cycle : String = ""
    var notificationType : String = ""
    var rank :String = ""
    var winnerCode : String = ""
    
    func initSSENotification(dic : NSDictionary?) -> Void{
        
        self.sseID = dic?["sse_id"] as? String ?? ""
        self.sseName = dic?["name"] as? String ?? ""
        self.imgUrl = dic?["image"] as? String ?? ""
        self.numOfPeak = dic?["no_of_peaks"] as? String ?? ""
        self.numOfWinners = dic?["no_of_winners"] as? String ?? ""
        self.current_cycle = dic?["current_cycle"] as? String ?? ""
        let n_id: Int = dic?["type"] as! Int
        self.notificationType = String(n_id)
        
        let n_rank: Int = dic?["rank"] as! Int
        self.rank = String(n_rank)
//        self.notificationType = dic?["type"] as? String ?? ""
        self.winnerCode = dic?["codes"] as? String ?? ""
    }
    
}
