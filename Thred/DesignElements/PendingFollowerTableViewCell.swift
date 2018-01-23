//
//  PendingFollowerTableViewCell.swift
//  Thred
//
//  Created by Thred. on 12/26/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class PendingFollowerTableViewCell: UITableViewCell {

    @IBOutlet var acceptButtonView: UIView!
    
    @IBOutlet var declineButtonView: UIView!
    
    @IBOutlet var acceptButton: UIButton!

    
    @IBOutlet var declineButton: UIButton!
    
    @IBOutlet var userNameTextField: UILabel!
    
    var user: BackendlessUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        helping.putSquareBorderOnButton(buttonView: acceptButtonView)
        helping.putSquareBorderOnButtonColor(buttonView: declineButtonView, color: UIColor.red)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
