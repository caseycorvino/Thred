//
//  TextPostTableViewCell.swift
//  Thred
//
//  Created by Thred. on 12/7/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class TextPostTableViewCell: UITableViewCell {

    @IBOutlet var textView: UILabel!
    
    @IBOutlet var commentsButton: UIButton!
    
    @IBOutlet var dateCreatedLabel: UILabel!
    
    @IBOutlet var likes: UILabel!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var flagButton: UIButton!
    
    @IBOutlet var likeBackground: UIView!
    
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
