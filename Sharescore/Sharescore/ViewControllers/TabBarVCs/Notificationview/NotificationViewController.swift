//
//  NotificationViewController.swift
//  Sharescore
//
//  Created by iOSpro on 3/11/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet var btn_ClearAll: UIButton!
    
    var loadingNotification:MBProgressHUD? = nil
    let refreshControl: UIRefreshControl = UIRefreshControl()
//    var refresh_Flag: Int = 0
    var isInDeleting : Bool = false
    
    var datas = ["Chur Burger", "Short Stop Donut", "Donut Time"]
    var datas2 = ["Congratulations! You've Won!", "Sorry, you didn't win this time.", "Awesome! You're in the lead!"]
    var datas3 = ["Claim your prize now", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableview.delegate = self
        tableview.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshAllDatas), for: .valueChanged)
        tableview.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAllDatas), name: NSNotification.Name(rawValue: "RefreshNotifications"), object: nil)
        clearNotificationBadge()
    }

    override func viewWillAppear(_ animated: Bool) {
        // check notification
        
    }
    
    func clearNotificationBadge(){
        
        let parameters = ["user_id": USER.id] as [String : Any]
        
        Alamofire.request(kAPI_ClearNotificationbadge, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (responseData) -> Void in
            //                SVProgressHUD.popActivity()
            if((responseData.result.value) != nil) {
                if (responseData.result.isSuccess){
                    
                }
            }
            //                self.refreshAllDatas()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Hide_Home_BadgeNumber), object: nil)
        notificationBadgeNumber = 0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshAllDatas(){
//        refresh_Flag = 1
        self.tableview.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    // Mark: - Clear Button
    
    @IBAction func ClearAllClicked(_ sender: Any) {
        if (self.isInDeleting){
            return
        }
        else{
            self.isInDeleting = true
            setCountdownTimer()
            self.loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.loadingNotification?.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification?.label.text = "Deleting..."
            
            let param = ["user_id": USER.id]
            
            Alamofire.request(kAPI_ClearNotification, method: .post, parameters: param).responseJSON { (responseData) -> Void in
                
                if((responseData.result.value) != nil) {
                    print(responseData.result)
                    if (responseData.result.isSuccess){
                        //appDelegate.initAppBadge()
                        myNotifications = [SSENotification]()
                        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Hide_Home_BadgeNumber), object: nil)
                    }
                }
                self.isInDeleting = false
            }
            
        }
    }
    
    //MARK - Set Timer for progressbar
    func setCountdownTimer(){
        var _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkRequestResult), userInfo: nil, repeats: true)
    }
    
    func checkRequestResult() {
        if (!isInDeleting){
            //self.refreshAllDatas()
            self.loadingNotification?.hide(animated: true)
            self.tableview.reloadData()
        }
    }

    // MARK: - Table Contents

     func numberOfSections(in tableview: UITableView) -> Int {
        return 1
     }
     
     func tableView(_ tableview: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
     }
     
     
     func tableView(_ tableview: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myNotifications.count
     }
     
     func tableView(_ tableview: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableview.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationsTBCell
     
        cell.lb_Title.text = myNotifications[indexPath.row].sseName
        cell.lb_Status.text = datas2[Int(myNotifications[indexPath.row].notificationType)!]
        
        let text3 = datas3[Int(myNotifications[indexPath.row].notificationType)!]
        cell.lb_Score.text = text3
        
        cell.lb_Title.font = UIFont.systemFont(ofSize: 18)
        cell.lb_Status.font = UIFont.systemFont(ofSize: 16)
        cell.lb_Score.font = UIFont.systemFont(ofSize: 16)
        
        if text3 == ""{
            cell.lb_Title.frame.origin.y = 20
            cell.lb_Status.frame.origin.y = 42
            cell.lb_Score.frame.origin.y = 45
        }
        else{
            cell.lb_Title.frame.origin.y = 8
            cell.lb_Status.frame.origin.y = 30
            cell.lb_Score.frame.origin.y = 52
        }
        
        let imgurl : String = myNotifications[indexPath.row].imgUrl
        cell.img_Avatar.sd_setImage(with: URL(string: imgurl))
        return cell
     
     }
     
     func tableView(_ tableview: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (myNotifications[indexPath.row].notificationType == "0"){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Notifi_DetailViewController") as! Notifi_DetailViewController
            viewController.selectedNotification = myNotifications[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        
        /*
        let indexPath = tableview.indexPathForSelectedRow //optional, to get from any UIButton for example
        let currentCell = tableview.cellForRow(at: indexPath!)! as! NotificationsTBCell
     
        currentCell.lb_Title?.text = "Selected"
        */
     
     }
 
}
