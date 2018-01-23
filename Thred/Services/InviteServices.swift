//
//  UserServices.swift
//  Thred
//
//  Created by Casey Corvino on 11/30/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import Foundation
import UIKit

//check email in external method wth regex

public class InviteServices{
    
    var backendless = Backendless.sharedInstance()
    
    func invitePhoneNumber(phone: String, view: UIViewController){
       
        
        let newInvite: Invite = Invite()
        newInvite.phone = phone;
        
        let dataStore = backendless?.data.of(Invite.ofClass())
        
        dataStore?.save(newInvite, response: { (res: Any?) in
            
            helping.displayAlertOKThenPush("Invited!", message: "The contact has been succesfully invited", view: view, nav: view.navigationController, story: view.storyboard, identifier: "signUpSuccess")//check identifier
            //send text to number
            
            
            
        }, error: { (fault: Fault?) in
            
            helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
            
        })
        
    }
    
    func deleteInvite(iniviteId: String){
        let dataStore = backendless?.data.of(Invite.ofClass())
       
        dataStore?.remove(byId: iniviteId, response: { (num: NSNumber?) in
            print("=====invite removed")
        }, error: { (fault: Fault?) in
            print("=====invite error \((fault?.message)!)")
        })
            
        
    }
    
    func isInvited(phone: String, email: String, completionHandler: @escaping (String)->()){
         let dataStore = backendless?.data.of(Invite.ofClass())
        let whereClause = "email = '\(email) OR phone = '\(phone)'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(whereClause)
        
        
        dataStore?.find(queryBuilder, response: { (res: [Any]?) in
            if let invite = res as? [Invite]{
                if (invite.count > 0){
                    completionHandler(invite[0].objectId!)
                } else {
                    completionHandler("none")
                }
            } else{
                completionHandler("none")
            }
        }, error: { (fault: Fault?) in
            completionHandler("none")
            print((fault?.message)!)
        })
        
    }
    
    func addToWaitlist(email: String, portfolio: String, view: UIViewController, completionHandler: @escaping (Bool)->()){
        let wait = Waitlist()
        wait.email = email;
        wait.portfolio = portfolio
        let dataStore = backendless?.data.of(Waitlist.ofClass())
        dataStore?.save(wait, response: { (res: Any?) in
            completionHandler(true)
        }, error: { (fault: Fault?) in
            print((fault?.message)!)
                helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
            completionHandler(false)
        })
    }
    

}

