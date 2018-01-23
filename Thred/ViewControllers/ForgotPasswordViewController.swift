//
//  ForgotPasswordViewController.swift
//  Thred
//
//  Created by Casey Corvino on 12/2/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helping.underlineTextField(field: emailTextField)
        // Do any additional setup after loading the view.
    }

    @IBAction func resetButtonClicked(_ sender: Any) {
        
        
        myUserServices.resetPassword(email: emailTextField.text!, view: self)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
