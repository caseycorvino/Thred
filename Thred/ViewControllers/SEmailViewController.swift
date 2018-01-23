//
//  SEmailViewController.swift
//  Thred
//
//  Created by Casey Corvino on 11/29/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class SEmailViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var confirmEmailTextField: UITextField!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helping.underlineTextField(field: emailTextField)
        helping.underlineTextField(field: confirmEmailTextField)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let userServices = MyUserServices()
        userServices.checkAndSetEmail(checkEmail: emailTextField.text!, checkConfirmEmail: confirmEmailTextField.text!, view: self, nav: navigationController, story: storyboard, identifier: "SPhone", completionHandler: {
                UIApplication.shared.endIgnoringInteractionEvents()
            })
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
   

}
