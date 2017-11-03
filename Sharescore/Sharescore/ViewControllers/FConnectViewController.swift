//
//  FConnectViewController.swift
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

class FConnectViewController: UIViewController {

    @IBOutlet weak var lb_intro: UILabel!
    @IBOutlet weak var btn_conFacebook: UIButton!
    
    var loadingNotification:MBProgressHUD? = nil
    let defaults : UserDefaults = UserDefaults.standard
    var txt_username : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btn_conFacebook.layer.cornerRadius = btn_conFacebook.bounds.height/2
        btn_conFacebook.clipsToBounds = true
        
        if let fbToken = defaults.string(forKey: kSSE_User_FB_Token) {
            print(fbToken)
            appDelegate.fbtokenstring = fbToken
            appDelegate.fb_id = defaults.string(forKey: kSSE_User_FB_Id)!
            appDelegate.fb_avatar = defaults.string(forKey: kSSE_User_FB_Avatar)!
            appDelegate.fbname = defaults.string(forKey: kSSE_User_FB_Name)!
            devToken = defaults.string(forKey: kSSE_APN_Device_Token)!
            
            self.LoginCheck()
        }
        
        //        self.checkFacebookSignInSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btn_conFacebook_Click(_ sender: UIButton) {
        ConnectToFacebook()
    }
    
    // MARK: - Navigation

    func ConnectToFacebook() {
        
//        if (FBSDKAccessToken.current() != nil){
//            getFBUserData()
//            print("Facebook Login")
//        }else{
        
            let fbLoginManager = FBSDKLoginManager()
            
            fbLoginManager.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
                if (error == nil){
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    if fbloginresult.grantedPermissions != nil {
//                        if(fbloginresult.grantedPermissions.contains("email"))
//                        {
                            self.getFBUserData()
                            
//                            FBSDKSession.openActiveSession(withReadPermissions: ["email"], allowLoginUI: true, completionHandler: {( session1: FBSDKSession,  status: FBSDKSessionState, _ error: Error?) -> Void in
//                                if session1.state == FBSessionStateOpen {
//                                    // then ask for publishing permission
//                                    if !self.checkFacebookPermissions(FBSession.activeSession) {
//                                        session1.requestNewPublishPermissions(["publish_actions"], defaultAudience: FBSessionDefaultAudienceFriends, completionHandler: {( session2: FBSession,  error: Error?) -> Void in
//                                            if session2.state == FBSessionStateOpenTokenExtended {
//                                                // THIS IS IT, THE GLORY FINISH
//                                            }
//                                        })
//                                    }
//                                }
//                            })
//
                            
//                        }
                    }
                }
            }
//        }
    }
    
    func getFBUserData(){
        
        self.loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingNotification?.mode = MBProgressHUDMode.indeterminate
        self.loadingNotification?.label.text = "Loading..."

        let accessToken = FBSDKAccessToken.current()
        defaults.set(accessToken?.tokenString, forKey: kSSE_User_FB_Token)

        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: accessToken?.tokenString, version: nil, httpMethod: "GET")
        appDelegate.fbtokenstring = accessToken!.tokenString
        graphRequest?.start(completionHandler: { (connection, result, error) -> Void in
            self.loadingNotification?.hide(animated: true)
            if(error == nil)
            {
                print("fetched user: \(String(describing: result))")
                let castedResult = result as! [String: Any]
                self.txt_username = castedResult["name"] as!  String
//              appDelegate.fb_email = castedResult["email"] as! String
                appDelegate.fb_id = castedResult["id"] as!  String
                appDelegate.fb_avatar = "http://graph.facebook.com/" + appDelegate.fb_id + "/picture?type=large"
                appDelegate.fbname = castedResult["name"] as!  String
                
                self.defaults.set(appDelegate.fb_id, forKey: kSSE_User_FB_Id)
                self.defaults.set(appDelegate.fb_avatar, forKey: kSSE_User_FB_Avatar)
                self.defaults.set(appDelegate.fbname, forKey: kSSE_User_FB_Name)
                self.LoginCheck()
            }
            else
            {
                print("error \(String(describing: error))")
            }
        })
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    //MARK: - Alamofire
    func LoginCheck(){
        self.loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingNotification?.mode = MBProgressHUDMode.indeterminate
        self.loadingNotification?.label.text = "Loading..."
        let parameters = ["fbname": appDelegate.fbname, "fbid": appDelegate.fb_id, "profile_picture": appDelegate.fb_avatar, "fbtoken": appDelegate.fbtokenstring, "device_token": devToken]
        Alamofire.request(kAPI_LoginCheck, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
            
            self.loadingNotification?.hide(animated: true)
            
            switch response.result {
            case .success(_):
                
                let jsonObject = JSON(response.result.value!)
                let status: String = jsonObject["status"].stringValue
                if (status == "true"){ //registerd
                    USER.initUserDataWithJSON(json: jsonObject["result"])
                    USER.fb_token = appDelegate.fbtokenstring
                    self.goToMainVC()
                }else{
                    self.goToChooseUsernameVC()
                }
                break
            case .failure( _):                
                self.goToChooseUsernameVC()
                /*
                print(error)
                COMMON.methodForAlert(titleString: kAppName, messageString: kLoginRequest, OKButton: kOkButton, CancelButton: "", viewController: self)
                */
                break
            }
            
        }
    }
    
    func checkFacebookSignInSetting(){
        
        let facebookAppID: String = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as! String
        print(" facebook app id \(facebookAppID) ")
        
        let accountStore = ACAccountStore()
        let emailReadPermisson: [AnyHashable: Any] = [ACFacebookAppIdKey: facebookAppID, ACFacebookPermissionsKey: ["email"], ACFacebookAudienceKey: ACFacebookAudienceFriends]
        let publishWritePermisson: [AnyHashable: Any] = [ACFacebookAppIdKey: facebookAppID, ACFacebookPermissionsKey: ["publish_actions"], ACFacebookAudienceKey: ACFacebookAudienceFriends]
        let facebookAccountType: ACAccountType? = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
        
        accountStore.requestAccessToAccounts(with: facebookAccountType, options: emailReadPermisson, completion: {(granted, error) -> Void in
            
            if (granted){
                accountStore.requestAccessToAccounts(with: facebookAccountType, options: publishWritePermisson, completion: {(granted, error) -> Void in
                    
                    if (granted){
                        
                        
                    }
                    else {
                        let alert = UIAlertController(title: "Alert", message: "Please sign into Facebook from Settings of device", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
            else{
                let alert = UIAlertController(title: "Alert", message: "Please sign into Facebook from Settings of device", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }

    func goToChooseUsernameVC(){
        let ChooseVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseUsernameViewController") as! ChooseUsernameViewController
        
        if (self.txt_username != ""){
            ChooseVC.txtname = self.txt_username
        }
        
        self.navigationController?.pushViewController(ChooseVC, animated: true)

    }
    
    func goToMainVC(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
}
