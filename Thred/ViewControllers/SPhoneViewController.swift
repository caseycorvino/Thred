//
//  SPhoneViewController.swift
//  Thred
//
//  Created by Thred. on 12/12/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class SPhoneViewController: UIViewController {

    @IBOutlet var phoneField: UITextField!
    
    @IBOutlet weak var JoinWaitlistButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helping.underlineTextField(field: phoneField)
        helping.putSquareBorderOnButton(buttonView: JoinWaitlistButton)
         navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        JoinWaitlistButton.isHidden = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let progressHUD = ProgressHUD(text: "Checking invite list...")
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        let userServices = MyUserServices()
        if(userServices.isValidPhone(phone: phoneField.text!)){
            let inviteServices = InviteServices()
            
            progressHUD.setup()
            progressHUD.show()
            sPhone = self.phoneField.text!
            inviteServices.isInvited(phone: sPhone!, email: sEmail!, completionHandler: { (inviteObj: String) in
                if inviteObj != "none"{
                    sInviteId = inviteObj
                    self.progressHUD.hide()
                    helping.pushViewController(nav: self.navigationController, story: self.storyboard, identifier: "SUsername")
                } else {
                    self.progressHUD.hide()
                    self.JoinWaitlistButton.isHidden = false;
                    helping.displayAlertOK("Invite Verification Error", message: "Your phone number or email was not on the invite list. You may join the waitlist for a chance to be invited", view: self)
                }
            })
        } else {
            helping.displayAlertOK("Invalid Phone", message: "Please enter a valid phone number", view: self)
        }
        
    }
    
    @IBAction func joinWaitlistButtonClicked(_ sender: Any) {
        
        helping.pushViewController(nav: self.navigationController, story: self.storyboard, identifier: "Waitlist")
        
    }
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
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
