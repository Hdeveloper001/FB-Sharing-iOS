//
//  ChangeUsernameViewController.swift
//  Sharescore
//
//  Created by iOSpro on 11/8/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class ChangeUsernameViewController: UIViewController{
    
    @IBOutlet var lb_oldUsername: UILabel!
    
    @IBOutlet var txt_newUsername: UITextField!
    
    @IBOutlet var btn_back: UIButton!
    @IBOutlet var btn_change: UIButton!
    
    var loadingNotification:MBProgressHUD? = nil
    
    var isInChanging : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        txt_newUsername.delegate = self
        txt_newUsername.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lb_oldUsername.text = USER.user_name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check notification
//        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Show_Home_BadgeNumber), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackclicked(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeUsername(_ sender: Any) {
        if (self.isInChanging){
            return
        }
        else{
            self.isInChanging = true
            setCountdownTimer()
            self.loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.loadingNotification?.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification?.label.text = "Loading..."
            let newUsername : String = txt_newUsername.text!
            let parameters = ["username": newUsername,
                              "fbid": appDelegate.fb_id,
                              "access_token": appDelegate.device_token,
                              "device_token": devToken] as [String : Any]
            print(newUsername)
            print(appDelegate.fb_id)
            print(appDelegate.device_token)
            print(devToken)
            
            Alamofire.request(kAPI_RegisterCheck, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
                
                self.loadingNotification?.hide(animated: true)
                print(response)
                switch response.result {
                    
                case .success(_):
                    appDelegate.user_name = self.txt_newUsername.text!
                    USER.user_name = self.txt_newUsername.text!
                    let alert = UIAlertController(title: "Alert", message: "Username changed successfully.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                    break
                case .failure( _):
                    let alert = UIAlertController(title: "Alert", message: "Username change failed. \n Try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                    break
                }
                
            }
        }
    }

    //MARK - Set Timer for progressbar
    func setCountdownTimer(){
        var _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkRequestResult), userInfo: nil, repeats: true)
    }
    
    func checkRequestResult() {
        if (!isInChanging){
            //self.refreshAllDatas()
            self.loadingNotification?.hide(animated: true)
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
    
        let txt_username : String = textField.text!
        if txt_username.range(of:"@") == nil{
            textField.text = "@" + textField.text!
        }
    }
    
}
