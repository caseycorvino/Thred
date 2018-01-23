//
//  SBirthdateViewController.swift
//  Thred
//
//  Created by Casey Corvino on 11/30/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class SBirthdateViewController: UIViewController {

    @IBOutlet var birthdateDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        
        if(myUserServices.isValidBirthdate(bDay: birthdateDatePicker.date)){
            
            helping.pushViewController(nav: navigationController, story: storyboard, identifier: "SUserContract")
        } else {
            helping.displayAlertOK("Invalid Birthdate", message: "You must be 18 years old or older to use Thred.", view: self)
        }
        
    }
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
}
