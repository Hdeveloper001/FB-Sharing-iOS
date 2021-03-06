//
//  CampaignTBCell.swift
//  Sharescore
//
//  Created by iOSpro on 17/03/2017.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

class CampaignTBCell: UITableViewCell {

    @IBOutlet weak var img_Avatar: UIImageView!
    @IBOutlet weak var lb_Title: UILabel!
    @IBOutlet weak var lb_Likes: UILabel!
    @IBOutlet weak var lb_Value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        img_Avatar?.layer.cornerRadius = (img_Avatar?.frame.size.height)! / 2
        img_Avatar?.layer.masksToBounds = true
        img_Avatar?.layer.borderWidth = 0
        img_Avatar?.layer.borderColor = UIColor.gray.cgColor

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
