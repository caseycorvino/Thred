//
//  CommentTableViewCell.swift
//  Thred
//
//  Created by Thred. on 12/7/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet var commentField: UILabel!
    
    @IBOutlet var flagButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
