//
//  ProfileTBCell.swift
//  Sharescore
//
//  Created by iOSpro on 16/03/2017.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

protocol ProfileTBCellDelegate {
    func clicked_btn_Close(cell: ProfileTBCell)
}

class ProfileTBCell: UITableViewCell {

    
    @IBOutlet weak var img_Logo: UIImageView!
    @IBOutlet weak var lb_Time: UILabel!
    @IBOutlet weak var img_Timer: UIImageView!
    
    @IBOutlet weak var img_Avatar: UIImageView!
    
    @IBOutlet weak var lb_Title: UILabel!
    
    @IBOutlet weak var lb_Likes: UILabel!
    
    @IBOutlet weak var lb_Value: UILabel!
    
    @IBOutlet var btn_Close: UIButton!
    
    var cellDelegate: ProfileTBCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        img_Avatar?.layer.cornerRadius = (img_Avatar?.frame.size.height)! / 2
        img_Avatar?.layer.masksToBounds = true
        img_Avatar?.layer.borderWidth = 0
        img_Avatar?.layer.borderColor = UIColor.gray.cgColor

    }

    @IBAction func click_btn_Close(_ sender: Any) {
        cellDelegate?.clicked_btn_Close(cell: self)
    }
    
}
