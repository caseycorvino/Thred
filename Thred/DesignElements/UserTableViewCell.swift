//
//  UserTableViewCell.swift
//  Thred
//
//  Created by Casey Corvino on 12/3/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet var userNameTextField: UILabel!
    
    @IBOutlet var followButtonView: UIView!
    
    @IBOutlet var followButton: UIButton!
    
    @IBOutlet weak var unacceptButton: UIButton?
    
    @IBOutlet weak var rating: UILabel!
    
    var user: BackendlessUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(unacceptButton != nil){
            helping.putSquareBorderOnButtonColor(buttonView: unacceptButton!, color: UIColor.red)
        }
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
