//
//  WaitlistViewController.swift
//  Thred
//
//  Created by Thred. on 1/23/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class WaitlistViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var portfolioField: UITextField!
    
    @IBOutlet weak var joinWailtlistButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
        helping.underlineTextField(field: emailField)
        helping.underlineTextField(field: portfolioField)
        helping.putSquareBorderOnButton(buttonView: joinWailtlistButton)
    }

    @IBAction func JoinWaitlistButtonClicked(_ sender: Any) {
        
        let inviteServices = InviteServices()
        inviteServices.addToWaitlist(email: emailField.text!, portfolio: portfolioField.text!, view: self) { (res: Bool) in
            if(res){
                helping.displayAlertOKThenToRoot("Wailtist Joined!", message: "Check your mail for an invite update. If you don't sign up when invited, your invitation may expire. ", view: self, nav: self.navigationController)
            }
        }
        
        
        
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
