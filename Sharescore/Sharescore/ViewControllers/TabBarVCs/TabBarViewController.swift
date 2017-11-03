//
//  TabBarViewController.swift
//  Sharescore
//
//  Created by iOSpro on 3/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TabBarViewController: UITabBarController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let screenSize: CGRect = UIScreen.main.bounds
    
    //Buttons
    
    let btn_Center: UIButton = UIButton(frame: CGRect(x: Main_Screen_Width / 5 * 2, y: 0, width: Main_Screen_Width / 5, height: 48))
    
    let btn_Tap01: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: Main_Screen_Width / 5, height: 48))
    let btn_Tap02: UIButton = UIButton(frame: CGRect(x: Main_Screen_Width / 5, y: 0, width: Main_Screen_Width / 5, height: 48))
    let btn_Tap03: UIButton = UIButton(frame: CGRect(x: Main_Screen_Width * 3 / 5, y: 0, width: Main_Screen_Width / 5, height: 48))
    let btn_Tap04: UIButton = UIButton(frame: CGRect(x: Main_Screen_Width * 4 / 5, y: 0, width: Main_Screen_Width / 5, height: 48))
    
    var img_Tap01: UIImageView? = UIImageView()
    var img_Tap02: UIImageView? = UIImageView()
    var img_Tap03: UIImageView? = UIImageView()
    var img_Tap04: UIImageView? = UIImageView()
    var img_Cetner: UIImageView? = UIImageView()
    
    var selectedPhoto : UIImage? = nil
    
    let lbl_Badge: UILabel? = UILabel(frame: CGRect(x: Main_Screen_Width / 5 + (Main_Screen_Width / 5 - CGFloat(button_width)) / 2 + 14, y: 8, width: 22, height: 22))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBGImageViewsLayout()
        setButtonsLayout()
        
        self.selectedIndex = 0
        setButtonBGImage(index: 0)
                
        NotificationCenter.default.addObserver(self, selector: #selector(setTabToProfileViewController), name: NSNotification.Name(rawValue: "SetTabToProfileView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setTabToHomeViewController), name: NSNotification.Name(rawValue: "SetTabToHomeView"), object: nil)
        
        let notificationName = Notification.Name(kNoti_Show_Home_BadgeNumber)
        NotificationCenter.default.addObserver(self, selector: #selector(showBadgeNumber), name: notificationName, object: nil)
        
        let notificationName0 = Notification.Name(kNoti_Hide_Home_BadgeNumber)
        NotificationCenter.default.addObserver(self, selector: #selector(hideBadgeNumber), name: notificationName0, object: nil)
        
        showBadgeNumber()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    //MARK: - Show and Hide BadgeNumber
    func showBadgeNumber(){
        self.lbl_Badge?.text = String(notificationBadgeNumber)
        self.changeBadgeState()
//        if (HasNewNotification){
            let param = ["user_id": USER.id]
            
            Alamofire.request(kAPI_GetNotificationsInBackground, method: .post, parameters: param).responseJSON { (responseData) -> Void in
                
                if((responseData.result.value) != nil) {
                    myNotifications = [SSENotification]()
                    if (responseData.result.isSuccess){
                        //appDelegate.initAppBadge()
                        let swiftyJsonVar = JSON(responseData.result.value!)
                        //sseList = [SSEvent]()
                        if let resData = swiftyJsonVar.arrayObject{
                            //print(resData)
                            for item in resData{
                                let jsonstring : String = (item as! NSDictionary)["json"] as? String ?? ""
                                
                                let dict = COMMON.convertToDictionary(text: jsonstring)
                                
                                let sseNotification : SSENotification = SSENotification()
                                sseNotification.initSSENotification(dic: dict! as NSDictionary)
                                myNotifications.insert(sseNotification, at: 0)
//                                notificationBadgeNumber = notificationBadgeNumber + 1
//                                myNotifications.append(sseNotification)
                                
                            }
                            if (self.selectedIndex == 1){
                                notificationBadgeNumber = 0
                            }
                            self.lbl_Badge?.text = String(notificationBadgeNumber)
                            self.changeBadgeState()
                        }
                    }
                }
            }
//        }
        
    }
    
    func changeBadgeState() {
        if (notificationBadgeNumber > 99){
            self.lbl_Badge?.sizeThatFits(CGSize(width: 30, height: 22))
            self.lbl_Badge?.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        }
        else{
            self.lbl_Badge?.sizeThatFits(CGSize(width: 22, height: 22))
            self.lbl_Badge?.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            if (notificationBadgeNumber == 0){
                self.lbl_Badge?.text = ""
                self.lbl_Badge?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshNotifications"), object: nil)
    }
    
    func hideBadgeNumber(){
        self.lbl_Badge?.text = ""
        self.lbl_Badge?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    // MARK: - setButtonsLayout
    func setButtonsLayout(){
        btn_Center.tag = 2
        btn_Center.addTarget(self, action: #selector(clickedCenterButton), for: .touchUpInside)
        self.tabBar.addSubview(btn_Center)
        
        btn_Tap01.tag = 0
        btn_Tap01.addTarget(self, action: #selector(clicked_Buttons), for: .touchUpInside)
        self.tabBar.addSubview(btn_Tap01)
        
        btn_Tap02.tag = 1
        btn_Tap02.addTarget(self, action: #selector(clicked_Buttons), for: .touchUpInside)
        self.tabBar.addSubview(btn_Tap02)
        
        btn_Tap03.tag = 3
        btn_Tap03.addTarget(self, action: #selector(clicked_Buttons), for: .touchUpInside)
        self.tabBar.addSubview(btn_Tap03)
        
        btn_Tap04.tag = 4
        btn_Tap04.addTarget(self, action: #selector(clicked_Buttons), for: .touchUpInside)
        self.tabBar.addSubview(btn_Tap04)

    }
    
    // MARK: - setBGImageViewsLayout
    
    func initBGImageViews(){
        let button_area = (Main_Screen_Width / 5 - CGFloat(button_width)) / 2
        img_Tap01 = UIImageView(frame: CGRect(x: Int(button_area) , y: 12, width: button_width, height: button_width))
        img_Tap02 = UIImageView(frame: CGRect(x: Int(Main_Screen_Width / 5 + button_area), y: 12, width: button_width, height: button_width))
        img_Tap03 = UIImageView(frame: CGRect(x: Int(Main_Screen_Width * 3 / 5 + button_area), y: 12, width: button_width, height: button_width))
        img_Tap04 = UIImageView(frame: CGRect(x: Int(Main_Screen_Width * 4 / 5 + button_area), y: 12, width: button_width, height: button_width))
        
        img_Cetner = UIImageView(frame: CGRect(x: Int(Main_Screen_Width * 2 / 5 + button_area), y: 12, width: button_width, height: button_width))
        
        initImages()
    }
    
    func initImages(){
        img_Tap01?.image = UIImage(named: "Homex36.png")
        img_Tap02?.image = UIImage(named: "Notificationsx36.png")
        img_Tap03?.image = UIImage(named: "Profilex36.png")
        img_Tap04?.image = UIImage(named: "Settingsx36.png")
        img_Cetner?.image = UIImage(named: "Addx36.png")

    }
    
    func setBGImageViewsLayout(){
        initBGImageViews()
        
        lbl_Badge?.text = ""
        lbl_Badge?.backgroundColor = UIColor.red
        lbl_Badge?.textColor = UIColor.white
        lbl_Badge?.textAlignment = .center
        lbl_Badge?.font = UIFont.systemFont(ofSize: 14)
        
        lbl_Badge?.layer.cornerRadius = COMMON.HEIGHT(view: lbl_Badge!) / 2
        lbl_Badge?.clipsToBounds = true
        
        self.tabBar.addSubview(img_Tap01!)
        self.tabBar.addSubview(img_Tap02!)
        self.tabBar.addSubview(img_Tap03!)
        self.tabBar.addSubview(img_Tap04!)
        self.tabBar.addSubview(img_Cetner!)
        self.tabBar.addSubview(lbl_Badge!)
    }
    
    func clicked_Buttons(sender: UIButton?){
        if (sender?.tag == 2){ return}
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.campaingTitle = ""
        
        setButtonBGImage(index: (sender?.tag)!)
        
        let index : Int = (sender?.tag)!
        if (index == 0 ) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PopUpToHomeView"), object: nil)
        }
        else if (index == 1){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PopUpToNotificationView"), object: nil)
        }

        self.selectedIndex = index
    }
    
    func setButtonBGImage(index: Int){
        initImages()
        
        switch index {
        case 0:
            img_Tap01?.image = UIImage(named: "Home_activex36.png")
            break
        case 1:
            img_Tap02?.image = UIImage(named: "Notifications_activex36.png")
            break
        case 3:
            img_Tap03?.image = UIImage(named: "Profile_activex36.png")
            break
        case 4:
            img_Tap04?.image = UIImage(named: "Settings_activex36.png")
            break
        default:
            break
        }
    }
    
    func clickedCenterButton(){
        showCameraMenu()
    }
    
    // MARK: - Configure Center Tapbar Item

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (item.tag == 2){
            showCameraMenu()
        }
        
        if (item.tag == 1){ //Hide Badge Number
            NotificationCenter.default.post(name: Notification.Name(kNoti_Hide_Home_BadgeNumber), object: nil)
        }else{
            NotificationCenter.default.post(name: Notification.Name(kNoti_Show_Home_BadgeNumber), object: nil)
        }
    }
    
    // MARK: - Set Tab index to ProfileView after sharing
    func setTabToProfileViewController(){
        setButtonBGImage(index: 3)
        self.selectedIndex = 3
        
    }
    
    func setTabToHomeViewController(){
        setButtonBGImage(index: 0)
        self.selectedIndex = 0
        
    }
    
    //MARK: - Image Processing
    func showCameraMenu(){
        
        CURRENT_SSE = SSEvent()
        
        let bounds = UIScreen.main.bounds
        
        let testFrame : CGRect = CGRect(x:bounds.width / 2 , y: bounds.height , width:120, height:100)
        let testView : UIView = UIView(frame: testFrame)
        testView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.view.addSubview(testView)
        
        let attributedString = NSAttributedString(string: "Share", attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 22), //your font here
            NSForegroundColorAttributeName : UIColor.black
            ])
        
        let alertController = UIAlertController(title: "Share", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.popoverPresentationController?.sourceView = testView
        alertController.setValue(attributedString, forKey: "attributedTitle")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("Cancel")
            
//            cancelAlertController()
        }
        
        let cameraAction = UIAlertAction(title: "Take photo", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("Camera")
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("Photo Library")
            self.imporFromPhotoLibrary()
            
        }
        
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
       
    func imporFromPhotoLibrary(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated: false, completion: nil)
        
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (String(describing: info[UIImagePickerControllerMediaType]) == "Optional(public.movie)") {
            
            
        }else{
            
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SharePhotoViewController") as! SharePhotoViewController
            
            if let compressedData = UIImageJPEGRepresentation(image!, 0.8) {
                let jpgImage: UIImage? = UIImage(data: compressedData)
                viewController.img_Avatar = jpgImage
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else{
                
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func cancelAlertController(){
        
    }
}
