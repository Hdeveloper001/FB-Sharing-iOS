//
//  ProfileViewController.swift
//  Sharescore
//
//  Created by iOSpro on 3/11/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import SVProgressHUD

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ProfileTBCellDelegate {

    @IBOutlet weak var tv_profile: UITableView!
    @IBOutlet var lb_username: UILabel!
    
    var loadingNotification:MBProgressHUD? = nil
    
    var isInDeleting : Bool = false
    
//    var datas = ["Chur Burger", "Tella Balls", "Donut Time", "Short Stop Donuts", "five", "six"]
    
    //var Likes = ["675", "654", "632", "568", "563", "523", "489", "453", "443", "412", "390", "386", "365", "353", "331", "285", "253", "245", "294", "220"]
    
//    var Ranks = ["7", "5", "3", "14", "35", "26"]
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var refresh_Flag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tv_profile.delegate = self
        tv_profile.dataSource = self
        self.tv_profile.separatorStyle = .none
        refreshControl.addTarget(self, action: #selector(refreshAllDatas), for: .valueChanged)
        tv_profile.addSubview(refreshControl)
        lb_username.text = USER.user_name        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check notification
//        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Show_Home_BadgeNumber), object: nil)
        
        getUserDetails()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        getUserDetails()
//    }

    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.popActivity()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - refreshAllDatas
    func refreshAllDatas(){
        refresh_Flag = 1
        getUserDetails()
    }

    
    func getUserDetails() -> Void{
        
        SVProgressHUD.show()
        
        let parameters = ["access_token": USER.deviceToken, "id": USER.id]
        
        Alamofire.request(kAPI_GetUserDetail, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (responseData) -> Void in
            SVProgressHUD.popActivity()
            if (self.refresh_Flag == 0){
                
            }else{
                self.refreshControl.endRefreshing()
            }
            
            if((responseData.result.value) != nil) {
                if (responseData.result.isSuccess){
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    myApplications = [Applicant]()
                    if let resData = swiftyJsonVar["result"]["userposts"].arrayObject{
                        for sse in resData{
                            let applicant = Applicant()
                            applicant.initUserDataWithDictionary(value: sse as? NSDictionary)
                            myApplications.append(applicant)
                        }                        
                    }
                    self.tv_profile.reloadData()
                    
                }
                
            }
        }
        
    }
    
    func getRemainingTime(endDateTime : String, duration : String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ("yyyy-MM-dd HH:mm:ss")
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let time_end : Date = dateFormatter.date(from: endDateTime)!
        let time_current : Date = Date()
        
        let interval = time_end.timeIntervalSince(time_current)
        
        let time_remaining = Int(interval)
        if (time_remaining < 0){
            return "00:00"
        }
        
        let time_duration : Int = Int(duration)! * 60
        let time_cycle_remaining = time_remaining % time_duration
        let time_remain_min = Int(time_cycle_remaining / 60) > 9 ? String(Int(time_cycle_remaining / 60)) : "0" + String(Int(time_cycle_remaining / 60))
        let time_remain_sec = Int(time_cycle_remaining % 60) > 9 ? String(Int(time_cycle_remaining % 60)) : "0" + String(Int(time_cycle_remaining % 60))
        
        let str_time_remain = "- " + String(time_remain_min) + ":" + String(time_remain_sec)
        return str_time_remain
    }  
    
    func deleteUserPost(postid : String) -> Void{
        
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:{ (action: UIAlertAction!) in
            
            SVProgressHUD.show()
            let parameters = ["access_token": USER.deviceToken, "post_id": postid] as [String : Any]
            
            Alamofire.request(kAPI_DeleteUserPost, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (responseData) -> Void in
                SVProgressHUD.popActivity()
                if((responseData.result.value) != nil) {
                    if (responseData.result.isSuccess){
                        
                    }
                }
                self.refreshAllDatas()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            //                print("Handle Cancel Logic here")
        }))
        
        self.present(alert, animated: true, completion: nil)
       
    }
    
    // MARK: - Tableview
    
    func numberOfSections(in tv_profile: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tv_profile: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    
    func tableView(_ tv_profile: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myApplications.count
    }
    
    func tableView(_ tv_profile: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv_profile.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileTBCell
        cell.cellDelegate = self
        
        cell.lb_Title.text = myApplications[indexPath.row].sseName
        cell.img_Logo.sd_setImage(with: URL(string: myApplications[indexPath.row].postImageUrl))
        cell.img_Avatar.sd_setImage(with: URL(string: myApplications[indexPath.row].sseLogo))
        
        cell.lb_Time.text = getRemainingTime(endDateTime: myApplications[indexPath.row].sse_endDate, duration: myApplications[indexPath.row].sse_cycleDuration)
        
        cell.lb_Value.text = myApplications[indexPath.row].rank
        
        return cell
        
    }
    
    func tableView(_ tv_profile: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        getSelectedSSE(sseId: myApplications[indexPath.row].sse_id)
    }

    func getSelectedSSE(sseId: String){
        for sse in sseList{
            if (sse.id == sseId){
                CURRENT_SSE = sse
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CampaignViewController") as! CampaignViewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    // MARK: - ProfileTBCellDelegate
    func clicked_btn_Close(cell: ProfileTBCell) {
        let indexPath: IndexPath = tv_profile.indexPath(for: cell)!
        
        self.deleteUserPost(postid: myApplications[indexPath.row].postId)
        //tableView.reloadData()
    }
}
