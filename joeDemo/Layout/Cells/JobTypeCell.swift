//
//  JobTypeCell.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-15.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit

class JobTypeCell: UITableViewCell {
    
    @IBOutlet var cellView: UIView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
