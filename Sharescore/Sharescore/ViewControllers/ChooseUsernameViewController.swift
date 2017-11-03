//
//  ChooseUsernameViewController.swift
//  Sharescore
//
//  Created by iOSpro on 3/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit
import MBProgressHUD
import SwiftyJSON


class ChooseUsernameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var imgv_profile: UIImageView!
    @IBOutlet weak var lb_username: UILabel!
    @IBOutlet weak var txt_username: UITextField!
    @IBOutlet weak var lb_txtback: UILabel!
    
    public var txtname : String = ""
    
    var loadingNotification:MBProgressHUD? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txt_username.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setLayout()
    }
    
    func setLayout(){
        lb_username.text = txtname
        
        imgv_profile.sd_setImage(with: URL(string: appDelegate.fb_avatar))
        
        imgv_profile.layer.cornerRadius = COMMON.WIDTH(view: imgv_profile) / 2
        imgv_profile.clipsToBounds = true
        
        lb_txtback.layer.cornerRadius = lb_txtback.bounds.height/2
        lb_txtback.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Buttons' Events
    @IBAction func btn_Back_Click(_ sender: UIButton) {
        
        _ = self.navigationController?.popViewController(animated: true)
        /*
        let FconVC = self.storyboard?.instantiateViewController(withIdentifier: "FConnectViewController") as! FConnectViewController
        self.navigationController?.popToViewController(FconVC , animated: true)*/
    }
    
    @IBAction func btn_Next_Click(_ sender: UIButton) {
        appDelegate.user_name = txt_username.text!
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        let trimmedString = (appDelegate.user_name.trimmingCharacters(in: whitespace)) as String
        
        if (trimmedString == "" || trimmedString == "@"){
            COMMON.methodForAlert(titleString: kAppName, messageString: kEnterUserName, OKButton: kOkButton, CancelButton: "", viewController: self)
            return
        }
        
        RegisterUser()
    }

    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let txt_username : String = textField.text!
        if txt_username.range(of:"@") == nil{
            textField.text = "@" + textField.text!
        }
        
        //        animateViewMoving(true, moveValue: 167)
    }
    
    func textFieldDidChange(_ textField: UITextField) { //Handle the text changes here
        let txt_username : String = textField.text!
        if txt_username.range(of:"@") == nil{
            textField.text = "@" + textField.text!
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        animateViewMoving(false, moveValue: 167)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        txt_username.resignFirstResponder()
    }
    
    //MARK: - Alamofire
    func RegisterUser(){
        self.loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingNotification?.mode = MBProgressHUDMode.indeterminate
        self.loadingNotification?.label.text = "Loading..."
        
        let parameters = ["username": appDelegate.user_name,
                          "fbid": appDelegate.fb_id,
                          "access_token": appDelegate.device_token,
                          "device_token": devToken] as [String : Any]
        print(appDelegate.user_name)
        print(appDelegate.fb_id)
        print(appDelegate.device_token)
        print(devToken)
        
        Alamofire.request(kAPI_RegisterCheck, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
            
            self.loadingNotification?.hide(animated: true)
            print(response)
            switch response.result {
                
            case .success(_):
                
                let jsonObject = JSON(response.result.value!)
                let status: String = jsonObject["status"].stringValue
                if (status == "true"){ //registerd
                    print(jsonObject["result"])
                    USER.initUserDataWithJSON(json: jsonObject["result"])
                    print(USER.deviceToken)
                    self.goToMainVC()
                }else{
                    COMMON.methodForAlert(titleString: kAppName, messageString: kRegisterRequest, OKButton: kOkButton, CancelButton: "", viewController: self)
                }
                break
            case .failure( _):
//                self.goToMainVC()
//                print(error)
                
                COMMON.methodForAlert(titleString: kAppName, messageString: kRegisterRequest, OKButton: kOkButton, CancelButton: "", viewController: self)
                /**/
                break
            }
            
        }
    }

    func goToMainVC(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }

}
