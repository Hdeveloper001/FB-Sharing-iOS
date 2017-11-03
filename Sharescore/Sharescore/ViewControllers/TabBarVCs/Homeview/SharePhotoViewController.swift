//
//  SharePhotoViewController.swift
//  Sharescore
//
//  Created by iOSpro on 21/03/2017.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit
import Social
import MBProgressHUD
import FacebookShare
import FacebookCore
import FBSDKCoreKit
import Alamofire
import SwiftyJSON

class SharePhotoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    @IBOutlet weak var btn_Back: UIButton!
    @IBOutlet weak var btn_Share: UIButton!

    @IBOutlet weak var lb_ViewTitle: UILabel!
    
    @IBOutlet weak var img_Photo: UIImageView!
    
    @IBOutlet weak var txt_ChooseLocation: UITextField!
    
    @IBOutlet weak var View_SearchBar: UIView!
    @IBOutlet weak var View_Main: UIView!
    @IBOutlet weak var View_SearchArea: UIView!
    
    @IBOutlet weak var View_Board: UIView!
    @IBOutlet weak var View_TableArea: UIView!
    
    @IBOutlet weak var View_LabelBar: UIView!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var lc_SearchAreaTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var txt_caption: UITextView!
    
    var loadingNotification:MBProgressHUD? = nil
    
    var img_Avatar : UIImage? = nil
    var rect_View_Board_Origin : CGRect? = nil
    var isInPosting : Bool = false
    
    var filteredSSEList = [SSEvent]()
    
    let shareButton = FBSDKShareButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        txt_caption.delegate = self
        
        txt_ChooseLocation.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
 
        if img_Avatar != nil {
            img_Photo.image = img_Avatar
        }
        //rect_View_Board_Origin = self.View_Board.frame
        btn_Share.addTarget(self, action: #selector(postFacebook(_:)), for: .touchUpInside)
        self.tableview.separatorStyle = .none

        if txt_ChooseLocation.text != ""{
            txt_ChooseLocation.isUserInteractionEnabled = false
        }
        else if (CURRENT_SSE.ssName != ""){
            txt_ChooseLocation.text = CURRENT_SSE.ssName
            txt_ChooseLocation.isUserInteractionEnabled = false
        }
        else
        {
            txt_ChooseLocation.placeholder = "Choose location"
            for sse in sseList{
                filteredSSEList.append(sse)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initRects()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }

    func initRects(){
        
        rect_View_Board_Origin = self.View_Board.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: - add caption to sharing
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.txt_caption.text = ""
        self.txt_caption.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    // MARK: - Animation for choose location
    @objc private func textFieldDidChange(_ txt_ChooseLocation: UITextField) {
        
        UIView.animate(withDuration: 0.3, animations: {
        
            var rect: CGRect = self.View_Main.bounds
            rect.origin.y = 0
            self.View_Board.frame = rect
            self.lc_SearchAreaTopConstraint.constant = self.View_LabelBar.frame.height * (-1)
            self.lb_ViewTitle.text = "Choose Location"
            
        }, completion: nil)
        
        filteredSSEList = [SSEvent]()
        for sse in sseList{
            if (txt_ChooseLocation.text == ""){
                filteredSSEList.append(sse)
            }
            else if (sse.ssName.contains(txt_ChooseLocation.text!)){
                filteredSSEList.append(sse)
            }
        }
        
        tableview.reloadData()
    }
    
    
    
    // MARK: - Retake Photo
    @IBAction func btn_Back_Clicked(_ sender: Any) {
        CURRENT_SSE = SSEvent()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Sharing Photo to Facebook
    func postFacebook(_ sender: UIButton){
        self.txt_caption.endEditing(true)
        
        if (self.isInPosting){
            return
        }
        else{
            self.loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.loadingNotification?.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification?.label.text = "Posting..."

            if FBSDKAccessToken.current().hasGranted("publish_actions") {
                // TODO: publish content.
                postMountainImage()
            }
            else {
                postMountainImage()
            }
        }
    }
    
    func postMountainImage(){
        
        setCountdownTimer()
        self.isInPosting = true
//        let facebookAppID: String = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as! String
//        print(" facebook app id \(facebookAppID) ")
//        var facebookAccount: ACAccount?
//        let accountStore = ACAccountStore()
//        let emailReadPermisson: [AnyHashable: Any] = [ACFacebookAppIdKey: facebookAppID, ACFacebookPermissionsKey: ["email"], ACFacebookAudienceKey: ACFacebookAudienceFriends]
//        let publishWritePermisson: [AnyHashable: Any] = [ACFacebookAppIdKey: facebookAppID, ACFacebookPermissionsKey: ["publish_actions"], ACFacebookAudienceKey: ACFacebookAudienceFriends]
//        let facebookAccountType: ACAccountType? = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
//       
//        accountStore.requestAccessToAccounts(with: facebookAccountType, options: emailReadPermisson, completion: {(granted, error) -> Void in
//            self.isInPosting = true
//            if (granted){
//                accountStore.requestAccessToAccounts(with: facebookAccountType, options: publishWritePermisson, completion: {(granted, error) -> Void in
////
//                    if (granted){
//        
//                        print("Granded for post")
//                        let accounts: [Any] = accountStore.accounts(with: facebookAccountType)
//                        facebookAccount = accounts.last as? ACAccount
//                        print("Successfull access for account:" + (facebookAccount?.username)!)
                        var additionalcaption : String = self.txt_caption.text
                        if (additionalcaption == "Add caption (optional)")
                        {
                            additionalcaption = ""
                        }
                        
                        let caption : String = /*self.txt_ChooseLocation.text! + " " + */CURRENT_SSE.hashcode + "\n" + additionalcaption
                        var parameters = [AnyHashable: Any]()
                        parameters = ["access_token": appDelegate.fbtokenstring as Any, "caption": caption, "place": CURRENT_SSE.locationId]
                        let feedURL: URL? = URL(string: "https://graph.facebook.com/me/photos")
                        
                        let feedRequest : SLRequest = SLRequest(forServiceType: SLServiceTypeFacebook, requestMethod: SLRequestMethod.POST, url: feedURL, parameters: parameters)
                       
                        let myData: Data? = UIImagePNGRepresentation(self.img_Avatar!)
                        
                        feedRequest.addMultipartData(myData as Data!, withName: "media", type: "image/png", filename: "Mountain")
                        feedRequest.perform(handler: {(responseData, urlResponse, error) ->Void in
                            
                            if (responseData == nil)
                            {
                                self.isInPosting = false
                                print("Facebook Post Failed")
                                let alert = UIAlertController(title: "Alert", message: "Facebook Post Failed", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            else{
                                
                                if urlResponse?.statusCode == 200 {
                                    do {
                                        let json = try JSONSerialization.jsonObject(with: responseData!, options: .allowFragments) as! [AnyHashable : Any]
                                        
                                        print("facebook details: \(json)")
                                        let fbId : String = (json["id"]) as! String
//                                        var registeredIdCount : Int = 0
//                                        if (UserDefaults.standard.object(forKey: "idcount") != nil){
//                                            registeredIdCount = UserDefaults.standard.object(forKey: "idcount") as! Int
//                                        }
//                                        registeredIdCount += 1
//                                        UserDefaults.standard.set(fbId, forKey: "fbid_\(registeredIdCount)")
//                                        UserDefaults.standard.set(registeredIdCount, forKey: "idcount")
//                                        UserDefaults.standard.synchronize()
                                        
                                        self.isInPosting = false
                                        print("Facebook Post succeeded")
                                        
                                        self.saveFBPostData(fb_postId: fbId, caption: caption)
                                        
                                        let alert = UIAlertController(title: "Alert", message: "Facebook Post succeeded", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: self.moveToHomescreen))
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }catch {
                                        let alert = UIAlertController(title: "Alert", message: "Facebook Post Failed", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        self.isInPosting = false
                                        print("Facebook Post Failed")
                                    }
                                }
                                else {
                                    let alert = UIAlertController(title: "Alert", message: "Facebook Post Failed", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    self.isInPosting = false
                                    print("Facebook Post Failed")
                                }
                            }
                        })
//                    }
//                    else {
//                        let alert = UIAlertController(title: "Alert", message: "Not granting publish_actions as admin user at the moment", preferredStyle: UIAlertControllerStyle.alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                        self.isInPosting = false
//                        print("Facebook Post Failed")
//                    }
////
//                })
//            }
//            else{
//                let alert = UIAlertController(title: "Alert", message: "Not granting publish_actions as admin user at the moment", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                self.isInPosting = false
//                print("Facebook Post Failed")
//            }
//        })
    }
    
    func moveToHomescreen (action: UIAlertAction){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SetTabToProfileView"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BackToHomeNavigationView"), object: nil)
    }
    
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableview: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSSEList.count
    }
    
    func tableView(_ tableview: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "SearchTBCell") as! SearchTBCell
        cell.img_Avatar.sd_setImage(with: URL(string: filteredSSEList[indexPath.row].imgUrl))
        cell.lb_Title.text = filteredSSEList[indexPath.row].ssName
        
        return cell
    }
    
    // MARK - Animation after chosen location
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //CODE TO BE RUN ON CELL TOUCH
        CURRENT_SSE = filteredSSEList[indexPath.row]
        
        self.lb_ViewTitle.text = "Share Photo"
        self.View_Board.frame = rect_View_Board_Origin!
        self.lc_SearchAreaTopConstraint.constant = 0
        self.txt_ChooseLocation.endEditing(true)
        self.txt_ChooseLocation.text = filteredSSEList[indexPath.row].ssName
        
    }
    
    //MARK - Set Timer for progressbar
    func setCountdownTimer(){
        var _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkRequestResult), userInfo: nil, repeats: true)
    }
    
    func checkRequestResult() {
        if (!isInPosting){
            self.loadingNotification?.hide(animated: true)
        }
    }
    
    // Mark - image Upload
    
    func saveFBPostData(fb_postId:String, caption: String) -> Void{
        
        let parameters = ["fb_id":USER.fb_id, "location":CURRENT_SSE.locationId, "image":"test", "caption":caption, "post_id":fb_postId, "access_token":USER.deviceToken, "sse_id":CURRENT_SSE.id] as [String : Any]
        
        Alamofire.request(kAPI_SaveFBPost, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
            
            switch response.result {
            case .success(_):
                let jsonObject = JSON(response.result.value!)
                let status: String = jsonObject["status"].stringValue
                if (status == "success"){
                    
                }else{
                    
                }
                break
            case .failure(let error):
                print(error)
                
                break
            }
        }
        
    }
    
}

