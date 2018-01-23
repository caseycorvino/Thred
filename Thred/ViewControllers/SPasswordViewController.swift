//
//  SPasswordViewController.swift
//  Thred
//
//  Created by Casey Corvino on 11/30/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class SPasswordViewController: UIViewController {

    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        helping.underlineTextField(field: passwordTextField);
        helping.underlineTextField(field: confirmPasswordTextField)
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
        userServices.checkAndSetPassword(checkPass: passwordTextField.text!, checkConfirmPass: confirmPasswordTextField.text!, view: self, nav: navigationController, story: storyboard, identifier: "SBirthdate", completionHandler: {
            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }

    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
}
