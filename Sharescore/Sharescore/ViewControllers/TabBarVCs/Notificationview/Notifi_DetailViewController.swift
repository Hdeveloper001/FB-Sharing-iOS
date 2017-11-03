//
//  Notifi_DetailViewController.swift
//  Sharescore
//
//  Created by iOSpro on 17/03/2017.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

class Notifi_DetailViewController: UIViewController {

    @IBOutlet var lb_sseName: UILabel!
    @IBOutlet var lb_placeNumber: UILabel!
    @IBOutlet var lb_winnerCode: UILabel!
    
    @IBOutlet var const_imgMedalTop: NSLayoutConstraint!
    @IBOutlet var const_imgMedalBottom: NSLayoutConstraint!
    
    var selectedNotification : SSENotification? = nil
    
    var isOpened : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (isOpened){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
            self.navigationController?.pushViewController(viewController, animated: false)
        }
        isOpened = true;
        
        NotificationCenter.default.addObserver(self, selector: #selector(popUpToNotificationViewController), name: NSNotification.Name(rawValue: "PopUpToNotificationView"), object: nil)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        lb_sseName.text = selectedNotification?.sseName
        lb_placeNumber.text = "Place " + (selectedNotification?.rank)! + "/" + (selectedNotification?.numOfWinners)!
        lb_winnerCode.text = selectedNotification?.winnerCode
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (IS_IPHONE_5){
            const_imgMedalTop.constant = 45
            const_imgMedalBottom.constant = 22
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(viewController, animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    func popUpToNotificationViewController(){
        _ = self.navigationController?.popViewController(animated: true)
    }


    @IBAction func btn_Back_Clicked(_ sender: Any) {
         _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK - Swipe Gesture
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                //change view controllers
                
                _ = self.navigationController?.popViewController(animated: true)
                
            default:
                break
            }
        }
    }

}
