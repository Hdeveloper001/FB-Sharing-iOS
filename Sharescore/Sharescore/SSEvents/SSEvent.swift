//
//  SSEvent.swift
//  Sharescore
//
//  Created by iOSpro on 22/06/2017.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import Foundation
import SwiftyJSON

class SSEvent: NSObject{
    var id: String = ""
    var ssName: String = ""
    var imgUrl: String = ""
    var sseDescription: String = ""
    var startDateTime : String = ""
    var endDateTime: String = ""
    var sseUrl = ""
    var totalCycle = ""
    var currentCycle = ""
    var cycleDuration = ""
    var hashcode = ""
    var locationId : String! = ""
    var timezone : String! = ""
    var myapplicationID : String = ""
    var winnerCodes = [String]()
    var applicants = [Applicant]()
    var isActivated : Bool = false
    var numOfWinnersPerCycle = ""
    
    
    func initUserData(){
        id = ""
        ssName = ""
        imgUrl = ""
        sseDescription = ""
        startDateTime = ""
        endDateTime = ""
        sseUrl = ""
        totalCycle = ""
        currentCycle = ""
        cycleDuration = ""
        hashcode = ""
        locationId = ""
        timezone = ""
        myapplicationID = ""
        isActivated = false
        numOfWinnersPerCycle = ""
        winnerCodes = [String]()
    }
    
    func setSSEData(sse : SSEvent) -> Void{
        
        id = sse.id
        ssName = sse.ssName
        imgUrl = sse.imgUrl
        sseDescription = sse.sseDescription
        startDateTime = sse.startDateTime
        endDateTime = sse.endDateTime
        sseUrl = sse.sseUrl
        totalCycle = sse.totalCycle
        currentCycle = sse.currentCycle
        cycleDuration = sse.cycleDuration
        hashcode = sse.hashcode
        locationId = sse.locationId
        timezone = sse.timezone
        myapplicationID = sse.myapplicationID
        numOfWinnersPerCycle = sse.numOfWinnersPerCycle
        winnerCodes = sse.winnerCodes
    }
    
    
    func initUserDataWithJSON(json: SwiftyJSON.JSON){
        id  = json["id"].stringValue
        ssName = json["name"].stringValue
        imgUrl = json["image_path"].stringValue
        sseDescription = json["description"].stringValue
        startDateTime = json["start_date"].stringValue
        endDateTime = json["end_date"].stringValue
        sseUrl = json["url"].stringValue
        totalCycle = json["no_of_peaks"].stringValue
        
        cycleDuration = json["peak_duration"].stringValue
        hashcode = json["hash_tag"].stringValue
        timezone = json["time_zone_offset"].stringValue
        locationId = json["facebook_location_id"].stringValue
        numOfWinnersPerCycle = json["no_of_winners"].stringValue
        
        
        //winnerCodes = json["codes"].arrayValue
    }
    
    
    func initUserDataWithDictionary(value: NSDictionary?){
        if (value != nil){
//            var temp_array = value?["codes"] as! String
//            
//            temp_array = temp_array.replacingOccurrences(of: "[[", with: "[")
//            temp_array = temp_array.replacingOccurrences(of: "],[", with: "]:[")
//            var temp = temp_array.components(separatedBy: ":")
            
            let n_id: Int = value?["id"] as! Int
            self.id = String(n_id)
            self.ssName = value?["name"] as? String ?? ""
            self.imgUrl = value?["image_path"] as? String ?? ""
            self.sseDescription = value?["description"] as? String ?? ""
            self.startDateTime = value?["start_date"] as? String ?? ""
            self.endDateTime = value?["end_date"] as? String ?? ""
            self.sseUrl = value?["url"] as? String ?? ""
            
            let n_totalcycle = value?["no_of_peaks"] as! Int
            totalCycle = String(n_totalcycle)
            
            let n_cycleduration = value?["peak_duration"] as! Int
            cycleDuration = String(n_cycleduration)
            hashcode = value?["hash_tag"] as? String ?? ""
            timezone = value?["time_zone_offset"] as! String
            locationId = value?["facebook_location_id"] as! String
            
            let n_numOfWinnersPerCycle: Int = value?["no_of_winners"] as! Int
            self.numOfWinnersPerCycle = String(n_numOfWinnersPerCycle)
            
            //numOfWinnersPerCycle = value?["no_of_winners"] as! String
        }
    }
    
}
