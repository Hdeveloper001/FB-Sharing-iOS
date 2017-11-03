//
//  PhotoViewController.swift
//  Sharescore
//
//  Created by iOSpro on 19/05/2017.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit


class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var img_Photoview: UIImageView!
    
    @IBOutlet var btn_Close: UIButton!
    
    @IBOutlet var imagecover: UIView!
    
    var imageurl : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeRight = UIPanGestureRecognizer(target: self, action: #selector(respondToTapdownGesture))
        self.imagecover.addGestureRecognizer(swipeRight)
        // Do any additional setup after loading the view.
        
        if (imageurl != ""){
            img_Photoview.sd_setImage(with: URL(string: imageurl))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func respondToTapdownGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UIPanGestureRecognizer {
            let velocity = swipeGesture.velocity(in: self.view)
            if (velocity.y > 0)
            {
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        }
    }   

}
