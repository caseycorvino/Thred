//
//  SUsernameViewController.swift
//  Thred
//
//  Created by Casey Corvino on 11/30/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class SUsernameViewController: UIViewController {

    @IBOutlet var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        helping.underlineTextField(field: usernameTextField)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        let userServices = MyUserServices()
        userServices.checkAndSetUsername(checkUsername: usernameTextField.text!, view: self, nav: navigationController, story: storyboard, identifier: "SPassword", completionHandler: {
            UIApplication.shared.endIgnoringInteractionEvents()
        })
        
    }
 
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
}
