//
//  SUserContractViewController.swift
//  Thred
//
//  Created by Casey Corvino on 11/30/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class SUserContractViewController: UIViewController {

    
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helping.underlineTextField(field: passwordField)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
       
        if(passwordField.text == sPassword){
            helping.pushViewController(nav: navigationController, story: storyboard, identifier: "SPrivacyPolicy")
        } else {
            helping.displayAlertOK("Invalid Password", message: "You must enter your password to agree to the User Contract", view: self)
        }
        
    }

    

}
