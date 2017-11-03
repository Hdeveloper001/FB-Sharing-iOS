//
//  SettingsViewController.swift
//  Sharescore
//
//  Created by iOSpro on 3/11/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var datas = ["Username", "Terms Of Use", "Privacy Policy", "Community Guidelines", "Rules", "Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check notification
//        NotificationCenter.default.post(name: NSNotification.Name(kNoti_Show_Home_BadgeNumber), object: nil)
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation

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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! SettingTBCell
        
        cell.lb_Setting.text = datas[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        var url : URL!
        switch indexPath!.row {
        case 0:
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeUsernameViewController") as! ChangeUsernameViewController
            self.navigationController?.pushViewController(viewController, animated: true)
            break
        case 1:
            url = URL(string: "https://www.sharescore.com.au/terms-of-use/")!
            break
        case 2:
            url = URL(string: "https://www.sharescore.com.au/privacy-policy")!
            break
        case 3:
            url = URL(string: "https://www.sharescore.com.au/community-guidelines")!
            break
        case 4:
            url = URL(string: "https://www.sharescore.com.au/rules")!
            break
        default:
            // log out action
            USER = User()
            CURRENT_SSE = SSEvent()
            _ = (appDelegate.window!.rootViewController as! UINavigationController).popViewController(animated: true)
            break
        }
        
        if (url == nil){
            
        }else{
            UIApplication.shared.openURL(url)
        }
    }
}
