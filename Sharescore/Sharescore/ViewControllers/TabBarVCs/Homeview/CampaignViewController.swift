//
//  CampaignViewController.swift
//  Sharescore
//
//  Created by iOSpro on 3/11/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import Social
import SwiftyJSON
import Alamofire
import SVProgressHUD

class CampaignViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var view_Main: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lb_Background: UILabel!
    @IBOutlet weak var btn_Back: UIButton!
    @IBOutlet weak var btn_Add: UIButton!
    
    @IBOutlet weak var view_Board: UIView!
    
    
    @IBOutlet weak var view_Explain: UIView!
    @IBOutlet weak var lb_Explain: UILabel!
    
    @IBOutlet weak var view_Tbl_Area: UIView!
    
    @IBOutlet var VEheightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var VEBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lb_BGBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lb_ExplainBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btn_MoreLess: UIButton!
    
//    @IBOutlet var btn_MoreBottomConstrait: NSLayoutConstraint!
    
    @IBOutlet weak var view_Tbl_Minor: UIView!
    
    @IBOutlet weak var view_BoardTitle: UIView!
    
    @IBOutlet weak var lc_TBM_BottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var view_Graphic_Core: UIView!
    @IBOutlet weak var view_Animation: UIView!
    
    @IBOutlet weak var img_CampaignAvatar: UIImageView!
    
    @IBOutlet weak var lb_Remaining_Time: UILabel!
    
    @IBOutlet var lb_cycleNumber: UILabel!
    
    @IBOutlet weak var view_LeaderBoard: UIView!
    
    @IBOutlet weak var lb_CampaignTitle: UILabel!
    
    @IBOutlet var myphotoavatar: UIImageView!
    
    @IBOutlet var myusername: UILabel!
    
    @IBOutlet var mylikes: UILabel!
    
    @IBOutlet var myranking: UILabel!
    
    var datas = [String]()
    var images = [String]()
    
    var Likes = [String]()
    var Ranks = [String]()
//    var Ranks = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]
    
    var isExpanded: Bool = false
    var rect_Origin_Lbl_Explain: CGRect = CGRect()
    var rect_Origin_View_Board: CGRect = CGRect()
    var rect_Origin_View_Explain: CGRect = CGRect()
    var rect_Origin_Tbl: CGRect = CGRect()
    var rect_Origin_Tbl_View: CGRect = CGRect()
    var rect_Origin_View_Animation : CGRect = CGRect()
    var rect_Origin_View_Graphic_Core : CGRect = CGRect()
    var str_Explain: String = ""
    
    public var str_CampaignTitle : String = ""
    
    var isTableExpanded : Bool = false

    var readLessGesture : UITapGestureRecognizer? = nil

    // MARK - Circular Animation
    var circleLayer: CAShapeLayer!

    var time_Remaining_Minute : Int = 0
    var time_Remaining_Second : Int = 0
    var time_totalSpent : Int = 0
    var time_total : Int = 0 // This will be the time period of each competition
    
    var timer = Timer()
    var loadfinished = false
    var registeredIdCount : Int = 0
    var stoploading = false
    var myApplication : Applicant? = nil
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var refresh_Flag: Int = 0
    
    // MARK: - Life cycle's functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        lb_Explain.text = CURRENT_SSE.sseDescription
        str_Explain = lb_Explain.text!
        NotificationCenter.default.addObserver(self, selector: #selector(popUpToHomeViewController), name: NSNotification.Name(rawValue: "PopUpToHomeView"), object: nil)
        
        let time_remaining = self.getRemainingTime(endDateTime: CURRENT_SSE.endDateTime, duration: CURRENT_SSE.cycleDuration)
        
        lb_Remaining_Time.text = time_remaining

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(touchLeaderBoard))
        view_LeaderBoard.addGestureRecognizer(gesture)
        let gesture2 = UIPanGestureRecognizer(target: self, action: #selector(touchLeaderBoard))
        view_BoardTitle.addGestureRecognizer(gesture2)

        lb_CampaignTitle.text = str_CampaignTitle
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.campaingTitle = lb_CampaignTitle.text!
        
        lb_CampaignTitle.text = CURRENT_SSE.ssName
        img_CampaignAvatar.sd_setImage(with: URL(string: CURRENT_SSE.imgUrl))

        img_CampaignAvatar.layer.cornerRadius = COMMON.WIDTH(view: img_CampaignAvatar) / 2
        img_CampaignAvatar.clipsToBounds = true
        
        myphotoavatar.layer.cornerRadius = COMMON.WIDTH(view: myphotoavatar) / 2
        myphotoavatar.clipsToBounds = true
        
        let moveToUrlGesture = UITapGestureRecognizer(target: self, action: #selector(moveToUrlDidClickedGesture))
        moveToUrlGesture.numberOfTapsRequired = 1
        img_CampaignAvatar.isUserInteractionEnabled = true
        img_CampaignAvatar.addGestureRecognizer(moveToUrlGesture)
        
        lb_cycleNumber.text = "Group " + CURRENT_SSE.currentCycle + "/" + CURRENT_SSE.totalCycle + "   |   " + "Winners " + CURRENT_SSE.numOfWinnersPerCycle
        
        datas = [String]()
        images = [String]()
        
        refreshControl.addTarget(self, action: #selector(refreshAllDatas), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // check notification
//        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Show_Home_BadgeNumber), object: nil)
        if (CURRENT_SSE.ssName == ""){
            _ = self.navigationController?.popViewController(animated: true)
        }
        getSSEDetail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (CURRENT_SSE.ssName == ""){
            _ = self.navigationController?.popViewController(animated: true)
        }
        else{
            initRects()
            
            self.addAnimationLayer(duration: time_total)
            setCountdownTimer()
            self.animateCircle(duration: time_total)
            
            var lineCount: Int = 0
            
            let str: String = str_Explain + "  less"
            let rect_Explain: CGSize = COMMON.getLabelSize(text: str as NSString, size: lb_Explain.bounds.size, font: lb_Explain.font)
            
            let charSize: Int = lroundf(Float(lb_Explain.font.lineHeight))
            lineCount = Int(rect_Explain.height) / charSize
            self.lb_Explain.numberOfLines = lineCount + 1
            
            let difference_Height: CGFloat = rect_Explain.height - rect_Origin_Lbl_Explain.size.height
            
            if (difference_Height <= 0){
                self.btn_MoreLess.setTitle("", for: UIControlState.normal)
                
            }
        }        
    }
    
    func refreshAllDatas(){
        refresh_Flag = 1
        getSSEDetail()
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
        
        let cycle_remaining = time_remaining / time_duration
        CURRENT_SSE.currentCycle = String(Int(CURRENT_SSE.totalCycle)! - cycle_remaining)
        let time_cycle_remaining = time_remaining % time_duration
        self.time_total = time_cycle_remaining
        
        let time_remain_min = Int(time_cycle_remaining / 60) > 9 ? String(Int(time_cycle_remaining / 60)) : "0" + String(Int(time_cycle_remaining / 60))
        let time_remain_sec = Int(time_cycle_remaining % 60) > 9 ? String(Int(time_cycle_remaining % 60)) : "0" + String(Int(time_cycle_remaining % 60))
        
        let str_time_remain = String(time_remain_min) + ":" + String(time_remain_sec)
        return str_time_remain
    }
    
    func moveToUrlDidClickedGesture(sender: UITapGestureRecognizer){
        
        var str_url = CURRENT_SSE.sseUrl
        var str_prefix = ""
        if (!str_url.contains("https://")){
            str_prefix = "https://"
        }
        if (!str_url.contains("www.")){
            str_prefix += "www."
        }
        str_url = str_prefix + str_url
        
        let url : URL! = URL(string: str_url)!
        
        if (url == nil){
            
        }else{
            if (UIApplication.shared.canOpenURL(url)){
                UIApplication.shared.openURL(url)
            }else{
                
                print ("cannot open url.")
            }
        }
    }
    
    // MARK - GET LIKES FROM FACEBOOK
    func GetSharescoreLikesFromFacebook(fbId : String, index : Int){
        
        if (fbId == ""){
            mylikes.text = "Likes 0"
            self.myranking.text = ""
            return
        }
        
        let facebookAppID: String = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as! String
        print(" facebook app id \(facebookAppID) ")
        var facebookAccount: ACAccount?
        let accountStore = ACAccountStore()
        let emailReadPermisson: [AnyHashable: Any] = [ACFacebookAppIdKey: facebookAppID, ACFacebookPermissionsKey: ["email"], ACFacebookAudienceKey: ACFacebookAudienceFriends]
        let publishWritePermisson: [AnyHashable: Any] = [ACFacebookAppIdKey: facebookAppID, ACFacebookPermissionsKey: ["user_posts"], ACFacebookAudienceKey: ACFacebookAudienceFriends]
        let facebookAccountType: ACAccountType? = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
        
        accountStore.requestAccessToAccounts(with: facebookAccountType, options: emailReadPermisson, completion: {(granted, error) -> Void in

            if (granted){
                accountStore.requestAccessToAccounts(with: facebookAccountType, options: publishWritePermisson, completion: {(granted, error) -> Void in
                    
                    if (granted){
                        
                        print("Granded for post")
                        let accounts: [Any] = accountStore.accounts(with: facebookAccountType)
                        facebookAccount = accounts.last as? ACAccount
                        print("Successfull access for account:" + (facebookAccount?.username)!)
                        
                        var parameters = [AnyHashable: Any]()
                        parameters = ["access_token": facebookAccount?.credential.oauthToken as Any]
                        let feedURL: URL? = URL(string: "https://graph.facebook.com/v2.7/" + fbId + "/likes")
                        
                        let feedRequest : SLRequest = SLRequest(forServiceType: SLServiceTypeFacebook, requestMethod: SLRequestMethod.GET, url: feedURL, parameters: parameters)
                        
                        feedRequest.perform(handler: {(responseData, urlResponse, error) ->Void in
                            
                            if urlResponse?.statusCode == 200 {
                                print("Facebook Post successfull")
                                do {
                                    
                                    let json = try JSONSerialization.jsonObject(with: responseData!, options: .allowFragments) as! [AnyHashable : Any]
                                    
                                    print("facebook details: \(json)")
                                    
                                    let fb_likes: [Any] = json["data"] as! [Any]
                                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                                    appdelegate.fb_likes = String(fb_likes.count)
                                    self.Likes.append(String(fb_likes.count))
                                    self.tableView.reloadData()
                                    
                                    if (index == self.registeredIdCount)
                                    {
                                        self.loadfinished = true
                                    }
                                    
                                }catch {
                                    
                                }
                            }
                            else {
                                print("Facebook Post Failed")
                            }
                        })
                        
                        
                    }
                })
            }
        })
    }
    
    
    func getSSEDetail() -> Void{
        SVProgressHUD.show()
        let parameters = ["access_token": USER.deviceToken, "id": CURRENT_SSE.id]
        
        Alamofire.request(kAPI_GetSSEDetail, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (responseData) -> Void in
            if (self.refresh_Flag == 0){
                
            }else{
                self.refreshControl.endRefreshing()
            }
            SVProgressHUD.popActivity()
            if((responseData.result.value) != nil) {
                if (responseData.result.isSuccess){
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    CURRENT_SSE.applicants = [Applicant]()
                    if let resData = swiftyJsonVar["result"]["userposts"].arrayObject{
                        for sse in resData{
                            let applicant = Applicant()
                            applicant.initUserDataWithDictionary(value: sse as? NSDictionary)
                            CURRENT_SSE.applicants.append(applicant)
                        }                        
                    }
                    self.initTableDatas()
                    if CURRENT_SSE.applicants.count > 0 {
                        for applicant in CURRENT_SSE.applicants{
                            
                            self.datas.append(applicant.username)
                            self.images.append(applicant.fb_profile_image)
                            self.Likes.append(applicant.fb_likescount)
                            self.Ranks.append(applicant.rank)
                            if (applicant.fb_userid == USER.fb_id){
                                    self.myApplication = applicant
                            }
                        }
                        
                        
                        if (self.myApplication != nil){
                            self.myphotoavatar.sd_setImage(with: URL(string: (self.myApplication?.fb_profile_image)!))
                            self.myusername.text = self.myApplication?.username
                            self.mylikes.text = "Facebook Likes " + (self.myApplication?.fb_likescount)!
                            self.myranking.text = self.myApplication?.rank
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func initTableDatas(){
        self.datas = [String]()
        self.images = [String]()
        self.Likes = [String]()
        self.Ranks = [String]()    
    }
    
    // MARK - Swipe Gesture
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                 _ = self.navigationController?.popViewController(animated: true) 
                
            default:
                break
            }
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.campaingTitle = ""
        }
    }
    
    // MARK - Add 2circle layers for background circle and animation circle.
    func addAnimationLayer(duration: Int){
        
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let time_cycle = Double(Int(CURRENT_SSE.cycleDuration)! * 60)
        let startvalue = Double(Double(time_cycle - Double(duration))/time_cycle) * 5.14
        
        let positionx = self.view_Main.frame.width / 2
        let positiony = self.rect_Origin_View_Board.origin.y + self.rect_Origin_View_Graphic_Core.origin.y + self.rect_Origin_View_Animation.origin.y + (self.rect_Origin_View_Animation.height / 2)
        
        let drawcirclePath = UIBezierPath(arcCenter: CGPoint(x: positionx, y: positiony), radius: (self.rect_Origin_View_Animation.size.width - 20)/2, startAngle: CGFloat(1.0 * (-1) + startvalue), endAngle: 4.14, clockwise: true)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: positionx, y: positiony), radius: (self.rect_Origin_View_Animation.size.width - 20)/2, startAngle: CGFloat(1.0 * (-1)), endAngle: 4.14, clockwise: true)
    
        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer = CAShapeLayer()
        circleLayer.path = drawcirclePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor(red: 96/255, green: 143/255, blue: 254/255, alpha: 1).cgColor
        circleLayer.lineWidth = 6.0;
        
        // Don't draw the circle initially
        circleLayer.strokeEnd = 0.0
        
        // Draw Background Circle
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.white.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        view_Board.layer.addSublayer(shapeLayer)
        
        //draw passed layer
        let passedcirclePath = UIBezierPath(arcCenter: CGPoint(x: positionx, y: positiony), radius: (self.rect_Origin_View_Animation.size.width - 20)/2, startAngle: CGFloat(1.0 * (-1)), endAngle: CGFloat(CGFloat(1.0 * (-1)) + CGFloat(startvalue)), clockwise: true)
        let passedLayer = CAShapeLayer()
        passedLayer.path = passedcirclePath.cgPath
        
        //change the fill color
        passedLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        passedLayer.strokeColor = UIColor(red: 96/255, green: 143/255, blue: 254/255, alpha: 1).cgColor
        //you can change the line width
        passedLayer.lineWidth = 6.0
        view_Board.layer.addSublayer(passedLayer)
        
        // Add the circleLayer to the view's layer's sublayers
        view_Board.layer.addSublayer(circleLayer)
    }
    
    // MARK - Animating circle
    func animateCircle(duration: Int) {
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = CFTimeInterval(duration)
        
        // Animate from 0 (no circle) to 1 (full circle)
        let time_cycle = Int(CURRENT_SSE.cycleDuration)! * 60
        
        animation.fromValue = Float(duration/time_cycle)
        animation.toValue = 1
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = 1.0
        
        // Do the actual animation
        circleLayer.add(animation, forKey: "animateCircle")
      
    }
    
    //MARK - Set Countdown Timer 
    func setCountdownTimer(){
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func updateCounter() {
        if(time_total > 0) {
            time_total -= 1
            
            self.time_Remaining_Minute = time_total / 60
            self.time_Remaining_Second = time_total % 60
            
            let str_Minute = self.time_Remaining_Minute > 9 ? String(self.time_Remaining_Minute) : "0" + String(self.time_Remaining_Minute)
            let str_Second = self.time_Remaining_Second > 9 ? String(self.time_Remaining_Second) : "0" + String(self.time_Remaining_Second)
            
            lb_Remaining_Time.text = str_Minute + ":" + str_Second
        }
    }
    
    func setLayout(){
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        lb_Background?.layer.cornerRadius = 8
        lb_Background?.layer.masksToBounds = true
        lb_Background?.layer.borderWidth = 0
        lb_Background?.layer.borderColor = UIColor.gray.cgColor
    }
    
    func initRects(){
        rect_Origin_Lbl_Explain = lb_Explain.frame
        rect_Origin_View_Board = view_Board.frame
        rect_Origin_View_Explain = view_Explain.frame
        rect_Origin_Tbl = view_Tbl_Area.frame
        rect_Origin_Tbl_View = tableView.frame
        rect_Origin_View_Animation = view_Animation.frame
        rect_Origin_View_Graphic_Core = view_Graphic_Core.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.popActivity()
        
    }
    
    func popUpToHomeViewController(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CampaignCell") as! CampaignTBCell
        
        cell.img_Avatar.sd_setImage(with: URL(string: images[indexPath.row]))
        cell.lb_Title.text = datas[indexPath.row]
        cell.lb_Likes.text = "Facebook Likes  " + Likes[indexPath.row]
        cell.lb_Value.text = Ranks[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        viewController.imageurl = CURRENT_SSE.applicants[indexPath.row].postImageUrl
        
        (appDelegate.window!.rootViewController as! UINavigationController).pushViewController(viewController, animated: true)
    }
    
    // MARK: - Button Actions
    
    @IBAction func btn_Back_Click(_ sender: Any) {
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.campaingTitle = ""
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btn_MyPostDetail_Click(_ sender: Any) {
        if (self.myApplication == nil){
            return
        }
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        viewController.imageurl = (self.myApplication?.postImageUrl)!
        
        (appDelegate.window!.rootViewController as! UINavigationController).pushViewController(viewController, animated: true)
    }
    
    @IBAction func btn_Add_Click(_ sender: Any) {
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
        }
        
        let cameraAction = UIAlertAction(title: "Take photo", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
            
            (appDelegate.window!.rootViewController as! UINavigationController).pushViewController(viewController, animated: true)
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
            viewController.img_Avatar = image
            self.navigationController?.pushViewController(viewController, animated: true)
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func btn_MoreLess_Clicked(_ sender: Any) {
        if (isExpanded == false){
            expandLabel()
        }
        else{
            decreaseLabel()
        }
    }
    
    func touchLeaderBoard(gesture : UIPanGestureRecognizer){
        if ((gesture.state == UIGestureRecognizerState.ended) || (gesture.state == UIGestureRecognizerState.failed)){
            if isExpanded{
                decreaseLabel()
            }
            if (self.isTableExpanded){
                self.decreaseTable()
                self.isTableExpanded = false
                self.tableView.setContentOffset(CGPoint.zero, animated: true)
            }
            else{
                self.expandTable()
                self.isTableExpanded = true
            }
        }
    }
    
    //private var StartAnimate: Bool = true
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isExpanded{
            decreaseLabel()
        }
       
        if (scrollView.contentOffset.y > 0) {
            // move up
            if self.isTableExpanded {
                
            }
            else {
                self.expandTable()
                self.isTableExpanded = true
            }
        }
        else if (scrollView.contentOffset.y < 0){
            // move down
            if isRowZeroVisible(){
                self.decreaseTable()
                self.isTableExpanded = false
            }
        }
        
        self.tableView.reloadData()
 /**/
    }
    
    func expandTable(){
        UIView.animate(withDuration: 0.3, animations: {
            var rect: CGRect = self.view_Main.bounds
            rect.origin.y = 0
            self.view_Tbl_Area.frame = rect
            self.lc_TBM_BottomConstraint.constant = (self.rect_Origin_View_Board.height + self.view_BoardTitle.frame.height - 35) * (-1)
        }, completion: nil)/**/
    }
    
    func decreaseTable(){
        
        let positionx : Int = 0
        let positiony : Int = Int(rect_Origin_View_Board.height )
        let rect: CGRect = CGRect(x: positionx, y: positiony, width: Int(self.view_Main.bounds.width), height: Int(self.view_Main.bounds.height) - Int(rect_Origin_View_Board.height))
        //var different : Int =
        UIView.animate(withDuration: 0.3, animations: {
            self.view_Tbl_Area.frame = rect
        }, completion: nil)
        
    }
    
    func isRowZeroVisible() -> Bool {
        let indexes: [IndexPath]? = tableView.indexPathsForVisibleRows
        for index: IndexPath in indexes! {
            if index.row == 0 {
                return true
            }
        }
        return false
    }
    
    func isRowLastVisible() -> Bool {
        let indexes: [IndexPath]? = tableView.indexPathsForVisibleRows
        let index_last : Int = tableView.numberOfRows(inSection: tableView.numberOfSections - 1)
        for index: IndexPath in indexes! {
            if index.row == index_last {
                return true
            }
        }
        return false
    }
    
    // MARK: - More button
    func addReadMoreStringToUILabel(label: UILabel?){
        let readMoreText = "  more"
        let lengthForString: Int = (label?.text?.characters.count)!
        let labelString: String = str_Explain
        
        var lengthForVisibleString: Int = 40
        if (IS_IPHONE_6){
            lengthForVisibleString = 40
        }else if(IS_IPHONE_6PLUS){
            lengthForVisibleString = 45
        }else if(IS_IPAD_1){
            lengthForVisibleString = 100
        }else if(IS_IPAD_2){
            lengthForVisibleString = 140
        }else if(IS_IPAD){
            lengthForVisibleString = 100
        }else{
            lengthForVisibleString = 40
        }
        
        let fontsize : CGFloat = self.lb_Explain.font.pointSize
        
        if (isExpanded == false){
            
            let mutableString: String = labelString
            if (lengthForString < lengthForVisibleString * 3){
                return
            }
            
            if (mutableString.contains("\n")){
                
            }
            var trimmedString: String = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString * 3, length: (lengthForString - lengthForVisibleString * 3)), with: "")
            let readMoreLength: Int = readMoreText.characters.count
            let trimmedForReadMore = (trimmedString as NSString).replacingCharacters(in: NSRange(location: ((trimmedString.characters.count ) - readMoreLength), length: readMoreLength ), with: "")
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSFontAttributeName: label?.font ?? UIFont.systemFont(ofSize: fontsize)])

            let readMoreAttributed = NSMutableAttributedString(string: readMoreText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: fontsize), NSForegroundColorAttributeName: UIColor.green])
            answerAttributed.append(readMoreAttributed)
            label?.attributedText = answerAttributed
            
            readLessGesture = UITapGestureRecognizer(target: self, action: #selector(readMoreDidClickedGesture))
            readLessGesture?.numberOfTapsRequired = 1
            label?.addGestureRecognizer(readLessGesture!)
            label?.isUserInteractionEnabled = true
            
            // added more button manually.
            findMoreButtonPosition()

        }
    }
    
    func findMoreButtonPosition(){
        
        let rect_current_View: CGRect = view_Explain.frame
        let positionx = /**/rect_current_View.origin.x + rect_current_View.width - 70
        let positiony = rect_current_View.origin.y + /**/rect_current_View.height - 50
        
        self.btn_MoreLess.frame = CGRect(x: positionx, y: positiony, width: 65, height: 45)
    }
    
    func findLessButtonPosition(){
        
        let rect_current_View: CGRect = view_Explain.frame
        let rect_current_Label: CGRect = lb_Explain.frame
        let positionx : Int = Int(rect_current_View.origin.x) + 60
        let positiony : Int = Int(rect_current_View.origin.y + rect_current_Label.height)
        
        self.btn_MoreLess.frame = CGRect(x: positionx, y: positiony, width: Int(rect_current_Label.width), height: 40)
        btn_MoreLess.addTarget(self, action: #selector(CampaignViewController.btn_MoreLess_Clicked(_:)), for: .touchUpInside)
    }
    
    func addLessStringToUILabel(label: UILabel?){
        let readMoreText = "  less"
        let lengthForString: Int = (label?.text?.characters.count)!
        let labelString: String = str_Explain
        
        let lengthForVisibleString: Int = lengthForString
        let fontsize : CGFloat = self.lb_Explain.font.pointSize
        
        if (isExpanded == true){
            
            let mutableString: String = labelString
            var trimmedString: String = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: (lengthForString - lengthForVisibleString)), with: "")
            let readMoreLength: Int = readMoreText.characters.count
            let trimmedForReadMore = (trimmedString as NSString).replacingCharacters(in: NSRange(location: ((trimmedString.characters.count ) - readMoreLength), length: readMoreLength), with: "")
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSFontAttributeName: label?.font ?? UIFont.systemFont(ofSize: fontsize)])
            
            let readMoreAttributed = NSMutableAttributedString(string: readMoreText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: fontsize), NSForegroundColorAttributeName: UIColor.green])
            answerAttributed.append(readMoreAttributed)
            label?.attributedText = answerAttributed
            
            let readLessGesture = UITapGestureRecognizer(target: self, action: #selector(readLessDidClickedGesture))
            readLessGesture.numberOfTapsRequired = 1
            label?.addGestureRecognizer(readLessGesture)
            label?.isUserInteractionEnabled = true
        }
    }
    
    func readMoreDidClickedGesture(sender: UITapGestureRecognizer){
        //expandLabel()
    }
    
    func readLessDidClickedGesture(sender: UITapGestureRecognizer){
        //decreaseLabel()
    }
    
    // MARK: - More button
    func expandLabel(){
        isExpanded = true
        
        //self.lb_Explain.lineBreakMode = NSLineBreakMode.byWordWrapping
        var lineCount: Int = 0
        
        let str: String = str_Explain + "  less"
        let rect_Explain: CGSize = COMMON.getLabelSize(text: str as NSString, size: lb_Explain.bounds.size, font: lb_Explain.font)
        
        let charSize: Int = lroundf(Float(lb_Explain.font.lineHeight))
        lineCount = Int(rect_Explain.height) / charSize
        self.lb_Explain.numberOfLines = lineCount + 1
        
        var rect_current_Board: CGRect = view_Board.frame
        var rect_current_View: CGRect = view_Explain.frame
        let rect_current_Table: CGRect = view_Tbl_Area.frame
        
        let difference_Height: CGFloat = rect_Explain.height - rect_Origin_Lbl_Explain.size.height + 20
        
        if (difference_Height <= 0){
            self.btn_MoreLess.setTitle("", for: UIControlState.normal)
            return
        }
     
        rect_current_View.size.height = rect_current_View.size.height + difference_Height
     
        readLessGesture = nil
        
        UIView.animate(withDuration: 0.3, animations: {
            
            rect_current_Board.size.height = rect_current_Board.size.height + difference_Height
            self.view_Board.frame = CGRect(x: rect_current_Board.origin.x , y: rect_current_Board.origin.y ,
                                              width: rect_current_Board.size.width, height: rect_current_Board.size.height + difference_Height)
            
            self.view_Tbl_Area.frame = CGRect(x: rect_current_Table.origin.x, y: rect_current_Table.origin.y + difference_Height,
                                              width: rect_current_Table.size.width, height: rect_current_Table.size.height - difference_Height)

            self.VEheightConstraint.constant += difference_Height
            self.VEBottomConstraint.constant = 12 + difference_Height * (-1)
            
        }, completion: nil)
        
        self.btn_MoreLess.setTitle("Less", for: UIControlState.normal)

    }
    
    func decreaseLabel(){
        isExpanded = false
        
        self.lb_Explain.lineBreakMode = NSLineBreakMode.byWordWrapping
        var lineCount: Int = 1
        
        let str: String = str_Explain + "  less"
        let rect_Explain: CGSize = COMMON.getLabelSize(text: str as NSString, size: lb_Explain.bounds.size, font: lb_Explain.font)
        
        let charSize: Int = lroundf(Float(lb_Explain.font.lineHeight))
        lineCount = Int(rect_Explain.height) / charSize
        self.lb_Explain.numberOfLines = lineCount + 1
    
        var rect_current_Board: CGRect = view_Board.frame
        var rect_current_View: CGRect = view_Explain.frame
        let rect_current_Table: CGRect = view_Tbl_Area.frame
        
        let difference_Height: CGFloat = rect_Explain.height - rect_Origin_Lbl_Explain.size.height + 20
        
        if (difference_Height <= 0){ return}
        
        rect_current_View.size.height = rect_current_View.size.height
        
        if ((lb_Explain.gestureRecognizers != nil) && (lb_Explain.gestureRecognizers?.count)! >= 0){
            lb_Explain.removeGestureRecognizer((lb_Explain.gestureRecognizers?[0])!)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
                        
            
            
            rect_current_Board.size.height = rect_current_Board.size.height - difference_Height
            self.view_Board.frame = CGRect(x: rect_current_Board.origin.x , y: rect_current_Board.origin.y ,
                                           width: rect_current_Board.size.width, height: rect_current_Board.size.height - difference_Height)
            
            self.view_Tbl_Area.frame = CGRect(x: rect_current_Table.origin.x, y: rect_current_Table.origin.y - difference_Height,
                                              width: rect_current_Table.size.width, height: rect_current_Table.size.height + difference_Height)
            
            self.VEheightConstraint.constant -= difference_Height
            self.VEBottomConstraint.constant = 12
            
        }, completion: nil)
       
        self.btn_MoreLess.setTitle("More", for: UIControlState.normal)
    }
    
}
