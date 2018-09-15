//
//  ChatCell
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-22.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet var cellView: UIView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
