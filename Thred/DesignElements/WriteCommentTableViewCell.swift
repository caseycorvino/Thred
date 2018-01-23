//
//  WriteCommentTableViewCell.swift
//  Thred
//
//  Created by Thred. on 12/7/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class WriteCommentTableViewCell: UITableViewCell {

    @IBOutlet var commentTextField: UITextField!
    
    @IBOutlet var postButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
