//
//  PendingSetTableViewCell.swift
//  Thred
//
//  Created by Thred. on 1/17/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class PendingSetTableViewCell: UITableViewCell {

    @IBOutlet weak var pendingCount: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        helping.putSquareBorderOnButtonColor(buttonView: pendingCount, color: helping.colors[3])
        titleLabel.font = titleLabel.font.withSize((UITableViewCell().textLabel?.font.pointSize)!)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
