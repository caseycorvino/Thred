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

var sEmail: String?
var sUsername:String?
var sPassword: String?
var sPhone: String?
var sInviteId: String?

public class MyUserServices{
    
    var backendless = Backendless.sharedInstance()
    
    
    func checkIfLoggedIn(view:UIViewController, completionHandler: @escaping()->()){
        let backendless = Backendless.sharedInstance()
        backendless?.userService.isValidUserToken({
            (result : NSNumber?) -> Void in
            if(result?.boolValue == true){
                
                backendless?.data.of(BackendlessUser.ofClass()).find(byId: followServices.getActiveUserId(), response: { (res: Any?) in
                    if let user = res as? BackendlessUser{
                       
                        backendless?.userService.currentUser = user
                        view.performSegue(withIdentifier: "loginSuccess", sender: nil)
                        completionHandler()
                    }
                }, error: { (fault: Fault?) in
                    print("Server reported an error: \(fault?.message ?? "Fault"))")
                    completionHandler()
                })
                
                
            } else {
                view.navigationController?.isNavigationBarHidden = true;
                view.navigationController?.navigationBar.isTranslucent = false;
                completionHandler()
            }
            
            print("Is login valid? - \(result?.boolValue ?? false)")
        },
                                                  error: {
                                                    (fault : Fault?) -> Void in
                                                    view.navigationController?.isNavigationBarHidden = true;
                                                    view.navigationController?.navigationBar.isTranslucent = false;
                                                    print("Server reported an error: \(fault?.message ?? "fault")")
                                                    completionHandler()
        })
    }
    func changePassword(view: UIViewController){
        let alert = UIAlertController(title: "Change Password?", message: "A reset password email will be sent", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            
            self.backendless?.userService.restorePassword((self.backendless?.userService.currentUser.email)! as String,
                                                     response: {
                                                        (result : Any) -> Void in
                                                        helping.displayAlertOKThenToRoot("Email Sent", message: "Please check your email inbox to reset your password", view: view, nav: view.navigationController)
                                                        print("Please check your email inbox to reset your password")
            },
                                                     error: {
                                                        (fault : Fault?) -> Void in
                                                        helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                                        print("Server reported an error: \(fault?.message ?? "Fault"))")
            })
            
        })))
        alert.addAction((UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
        })))
        view.present(alert, animated: true, completion: nil)
    }
    
    func logout(view: UIViewController){
        let alert = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
        })))
        alert.addAction((UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            
            self.backendless?.userService.logout({ (result: Any?) in
                print("User has been logged out")
                view.performSegue(withIdentifier: "logout", sender: nil)
                alert.dismiss(animated: true, completion: nil)
            },
                                            error: { (fault: Fault?) in
                                               
                                                helping.displayAlertOK("Server Reported an Rrror", message: (fault?.message)!, view: view)
                                                print("Server reported an error: \(String(describing: fault?.message))")
                                                alert.dismiss(animated: true, completion: nil)
            })
            
        })))
        view.present(alert, animated: true, completion: nil)
    }
    
    func resetPassword(email: String, view: UIViewController){
        
        if(isValidEmail(testStr: email)){
        backendless?.userService.restorePassword(email,
                                                 response: {
                                                    (result : Any) -> Void in
                                                    helping.displayAlertOKThenToRoot("Email Sent", message: "Please check your email inbox to reset your password", view: view, nav: view.navigationController)
                                                    print("Please check your email inbox to reset your password")
        },
                                                 error: {
                                                    (fault : Fault?) -> Void in
                                                    helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                                    print("Server reported an error: \(fault?.message ?? "Fault"))")
        })
        } else {
            helping.displayAlertOK("Invalid Email", message: "Please check the email field and try again", view: view)
        }
    }
    
    func login(email: String, password: String, view: UIViewController, completionHandler: @escaping ()->()) {
        
        if(isValidEmail(testStr: email) && isValidPassword(testStr: password)){
        backendless?.userService.login(email,
                                       password: password,
                                       response: {
                                        (loggedUser : BackendlessUser?) -> Void in
                                        self.backendless?.userService.setStayLoggedIn(true)
                                        view.navigationController?.isNavigationBarHidden = false;
                                        view.performSegue(withIdentifier: "loginSuccess", sender: nil)
                                        completionHandler()
        },
                                       error: {
                                        (fault : Fault?) -> Void in
                                       
                                        helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                        completionHandler()
        })
            
        } else {
          
            helping.displayAlertOK("Invalid Fields", message: "Please check your entered information and try again", view: view)
            completionHandler()
        }
    }
    
    
    
    func registerUser(view: UIViewController, nav: UINavigationController?, completionHandler: @escaping ()->()){
      
        if(sEmail == nil || sPassword == nil || sUsername == nil){
            helping.displayAlertOK("Unknown Error", message: "Unknown error found while trying to sign up. Please check all of your entered information", view: view)
            completionHandler()
            return;
        }
        let newUser = BackendlessUser()
        newUser.setProperty("email", object: sEmail!)
        newUser.name = sUsername! as NSString
        newUser.password = sPassword! as NSString
        newUser.setProperty("Phone", object: sPhone!)
        newUser.setProperty("likes", object: 0)
        newUser.setProperty("posts", object: 0)
        newUser.setProperty("hasInvite", object: true)
        
        backendless?.userService.register(newUser,
                                          response: {
                                            (registeredUser : BackendlessUser?) -> Void in
                                            
                                            print("User registered \(String(describing: registeredUser?.value(forKey: "email")!))")
                                            let inviteServices = InviteServices()
                                            inviteServices.deleteInvite(iniviteId: sInviteId!)
                                            helping.displayAlertOKThenToRoot("Success", message: "Sign up successfull. Please go back to the login screen and login", view: view, nav: nav)
                                            completionHandler()
        },
                                          error: {
                                            (fault : Fault?) -> Void in
                                            helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                            print("Server reported an error: \(String(describing: fault?.message))")
                                            completionHandler()
                                            
        })
        
        
    }
    
    func checkAndSetPassword(checkPass: String, checkConfirmPass:String, view: UIViewController, nav: UINavigationController?, story: UIStoryboard?, identifier: String, completionHandler: @escaping ()->()){
       
        if(checkPass == checkConfirmPass){
            if(isValidPassword(testStr: checkPass)){
                sPassword = checkPass;
                helping.pushViewController(nav: nav, story: story, identifier: identifier);
                completionHandler()
            } else {
                helping.displayAlertOK("Invalid Password", message: "Please check the password field and try again", view: view)
                completionHandler()
            }
        } else {
            helping.displayAlertOK("Passwords Don't Match", message: "Please check the password fields and try again", view: view)
            completionHandler()
        }
    }
    
    func checkAndSetUsername(checkUsername: String, view: UIViewController, nav: UINavigationController?, story: UIStoryboard?, identifier: String, completionHandler: @escaping ()->()){
       
        
            if isValidUsername(testStr: checkUsername){
                //check if email taken
                let query = DataQueryBuilder().setWhereClause("name = '\(checkUsername)'")
                _ = backendless?.data.of(BackendlessUser.ofClass()).find(query,
                                                                         //when complete check if found
                    response: { ( userObjects: [Any]?) in
                        if (userObjects?.count)! > 0{
                            helping.displayAlertOK("Invalid Username", message: "Username is already registered", view: view)
                            completionHandler();
                        } else{
                            //set variables
                            sUsername = checkUsername;
                            helping.pushViewController(nav: nav, story: story, identifier: identifier);
                            completionHandler()
                        }
                        
                }, //if error print error
                    error: { (fault: Fault?) in
                        helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                        completionHandler()
                })
                
            } else {
                helping.displayAlertOK("Invalid Username", message: "Please check the username field and try again", view: view)
                completionHandler()
            }
        
    }
    
    func checkAndSetEmail(checkEmail: String, checkConfirmEmail:String, view: UIViewController, nav: UINavigationController?, story: UIStoryboard?, identifier: String, completionHandler: @escaping ()->()){
        
        if(checkEmail == checkConfirmEmail){
            if isValidEmail(testStr: checkEmail){
                //check if email taken
                let query = DataQueryBuilder().setWhereClause("email = '\(checkEmail)'")
                _ = backendless?.data.of(BackendlessUser.ofClass()).find(query,
                                                                         //when complete check if found
                    response: { ( userObjects: [Any]?) in
                        if (userObjects?.count)! > 0{
                            //TODO Display Alert
                            helping.displayAlertOK("Invalid Email", message: "Email is already registered", view: view)
                            completionHandler();
                        } else{
                            //set variables
                            sEmail = checkEmail;
                            helping.pushViewController(nav: nav, story: story, identifier: identifier);
                            completionHandler()
                        }
        
                }, //if error print error
                    error: { (fault: Fault?) in
                        helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                        completionHandler()
                })
        
            } else {
                helping.displayAlertOK("Invalid Email", message: "Please check the email field and try again", view: view)
                completionHandler()
            }
        
        } else {
            helping.displayAlertOK("Emails Don't Match", message: "Please check the email fields and try again", view: view)
            completionHandler()
        }
    }
    
    //=================REGEX=========================
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func isValidUsername(testStr:String) -> Bool {
        let usernameRegEx = "^[0-9a-zA-Z\\_]{8,18}$"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluate(with: testStr)
    }
    func isValidPassword(testStr: String) -> Bool{
        let passwordRegEx = "^(?=.*[a-z].*[a-z].*[a-z]).{8,30}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: testStr)
    }
    func isValidPhone(phone: String)->Bool{
        let phoneRegex = "^[0-9]{10,14}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    
    
    //=================================================
    func isValidBirthdate(bDay:Date)-> Bool{
        let now = Date()
        let calendar = Calendar.current
        
        let ageComponent = calendar.dateComponents([.year], from: bDay, to: now)
        let age = ageComponent.year!
        if age >= 18{
            return true;
        }
        return false;
        
        
    }
}
