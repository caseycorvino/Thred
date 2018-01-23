//
//  SPrivacyPolicyViewController.swift
//  Thred
//
//  Created by Casey Corvino on 11/30/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class SPrivacyPolicyViewController: UIViewController {

    @IBOutlet var agreeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
      
        if(agreeSwitch.isOn){
            
            myUserServices.registerUser(view: self, nav: navigationController, completionHandler: {
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        } else {
            helping.displayAlertOK("Sign Up Error!", message: "You must agree to the Terms of Services and Privacy Policy to register", view: self)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
    }

}
