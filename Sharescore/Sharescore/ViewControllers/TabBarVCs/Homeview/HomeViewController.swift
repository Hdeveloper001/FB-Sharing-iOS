//
//  HomeViewController.swift
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

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    //var sseNames = [String]()
    //var sseUrls = [String]()
    //var sseDescriptions = [String]()
    //var sseEndDates = [String]()
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var refresh_Flag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        hideBadgeNumber()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorStyle = .none
        refreshControl.addTarget(self, action: #selector(refreshAllDatas), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        // check notification
//        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Show_Home_BadgeNumber), object: nil)
//        self.tableView.setContentOffset(CGPoint(x:0, y:self.tableView.contentOffset.y - (self.refreshControl.frame.size.height)), animated: true)
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
//            self.refreshControl.sendActions(for: .valueChanged)
//        })
        getSSEList()
//        refreshControl.beginRefreshing()
//        refreshControl.sendActions(for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.popActivity();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - refreshAllDatas
    func refreshAllDatas(){
        refresh_Flag = 1
        getSSEList()
    }    
    
    //MARK: - loadCommentsFromServer
    
    func getSSEList() -> Void{
        SVProgressHUD.show()
        let parameters = ["access_token": USER.deviceToken]
        print(parameters)
        Alamofire.request(kAPI_GetSSEList, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (responseData) -> Void in
            SVProgressHUD.popActivity()
            if (self.refresh_Flag == 0){
                
            }else{
                self.refreshControl.endRefreshing()
            }
            print(responseData.result)
            if((responseData.result.value) != nil) {
                if (responseData.result.isSuccess){
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    sseList = [SSEvent]()
                    if let resData = swiftyJsonVar["result"].arrayObject{
                        print(resData)
                        for sse in resData{
                            let ssevent = SSEvent()
                            ssevent.initUserDataWithDictionary(value: sse as? NSDictionary)
                            if (self.checkSSETime(startDateTime: ssevent.endDateTime)){
                                if (!self.checkSSETime(startDateTime: ssevent.startDateTime)){
                                    ssevent.isActivated = true
                                }
                                sseList.append(ssevent)
                            }
                            
                        }
                        
                    }
                    
                    self.tableView.reloadData()
                }
                
            }
        }
        
    }
    
    func checkSSETime(startDateTime:String) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ("yyyy-MM-dd HH:mm:ss")
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let time_start : Date = dateFormatter.date(from: startDateTime)!
        let time_current : Date = Date()
        
        let interval = time_start.timeIntervalSince(time_current)
        
        let time_remaining = Int(interval)
        if (time_remaining < 0){
            return false
        }
        return true
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
            return ""
        }
        
        let time_duration : Int = Int(duration)! * 60
        let time_cycle_remaining = time_remaining % time_duration
        let time_remain_min = Int(time_cycle_remaining / 60) > 9 ? String(Int(time_cycle_remaining / 60)) : "0" + String(Int(time_cycle_remaining / 60))
        let time_remain_sec = Int(time_cycle_remaining % 60) > 9 ? String(Int(time_cycle_remaining % 60)) : "0" + String(Int(time_cycle_remaining % 60))
        
        let str_time_remain = "- " + String(time_remain_min) + ":" + String(time_remain_sec)
        return str_time_remain
    }
    
    // Mark - Table contents
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sseList.count
    }    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell01") as! HomeTBCell
        
        cell.lb_Title.text = sseList[indexPath.row].ssName
        
        cell.lb_Title.font = UIFont.systemFont(ofSize: 19)
        
        cell.lb_StatusDetail.font = UIFont.systemFont(ofSize: 16)
        cell.lb_Timer.font = UIFont.systemFont(ofSize: 18)
        
        cell.img_Avatar.sd_setImage(with: URL(string: sseList[indexPath.row].imgUrl))
        
        cell.lb_StatusDetail.text = sseList[indexPath.row].sseDescription
        
        if (sseList[indexPath.row].isActivated){
            cell.lb_Timer.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
            cell.lb_Timer.text = getRemainingTime(endDateTime: sseList[indexPath.row].endDateTime, duration: sseList[indexPath.row].cycleDuration)
        }
        else{
            cell.lb_Timer.textColor = UIColor(red: 159/255, green: 159/255, blue: 159/255, alpha: 1.0)
            cell.lb_Timer.text = "00:00"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        let currentCell = tableView.cellForRow(at: indexPath!)! as! HomeTBCell
        
        initSSEWithData(index: (indexPath?.row)!) // get selected SSE
        if (CURRENT_SSE.isActivated){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CampaignViewController") as! CampaignViewController
//            viewController.str_CampaignTitle = currentCell.lb_Title.text!
            self.navigationController?.pushViewController(viewController, animated: true)
        }        
    }
    
    func initSSEWithData(index: Int) -> Void{
        
        CURRENT_SSE = sseList[index]
    }
    
}


