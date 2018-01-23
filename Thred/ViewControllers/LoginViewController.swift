//
//  ViewController.swift
//  Thred
//
//  Created by Casey Corvino on 11/29/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

let myUserServices = MyUserServices()

class LoginViewController: UIViewController {

    @IBOutlet var titleView: UIView!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var paswordTextField: UITextField!
    
    @IBOutlet var loginButtonView: UIView!
    
    @IBOutlet var signUpButtonView: UIView!
    
    @IBOutlet var forgotPasswordButton: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        let progressHUD = ProgressHUD(text: "Logging in")
        progressHUD.show()
        UIApplication.shared.beginIgnoringInteractionEvents()
        myUserServices.checkIfLoggedIn(view: self, completionHandler: {
             UIApplication.shared.endIgnoringInteractionEvents()
            progressHUD.hide()
        })
        
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        myUserServices.login(email: emailTextField.text!, password: paswordTextField.text!, view: self, completionHandler: {
            self.forgotPasswordButton.isHidden = false;
            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    @IBAction func forgotPasswordButtonClicked(_ sender: Any) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        navigationController?.isNavigationBarHidden = false;
        
        helping.pushViewControllerAnimated(nav: navigationController, story: storyboard, identifier: "forgotPassword")
        
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        navigationController?.isNavigationBarHidden = false;
       
        helping.pushViewController(nav: navigationController, story: storyboard, identifier: "SEmail")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        forgotPasswordButton.isHidden = true;
        helping.putBorderOnButton(buttonView: loginButtonView, radius: 20)
        helping.putSquareBorderOnButton(buttonView: signUpButtonView)
        helping.underlineTextField(field: emailTextField);
        helping.underlineTextField(field: paswordTextField);
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

