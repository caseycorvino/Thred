//
//  SettingsViewController.swift
//  Thred
//
//  Created by Casey Corvino on 12/2/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

var controller: MainFeedViewController?

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var nameField: UILabel!
    
    @IBOutlet var rateButton: UIButton!
    
     @IBOutlet var tableView: UITableView!
    
    var pendingCount = 0;
    
    var categories = ["My Account", "Account Settings", "More"]
    var settings = [["Followers","Following","Pending Followers","My Posts"],["Change Password","Logout"],["About","Contact"/*,"Invite Friends"*/,"Privacy Policy","Terms of Services","User Contract"]];
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath == [0,2]){
            if let cell = tableView.dequeueReusableCell(withIdentifier: "pendingCell") as? PendingSetTableViewCell{
                
                cell.pendingCount.isHidden = false;
                if(pendingCount == 0 || pendingCount == -1){
                    cell.pendingCount.isHidden = true;
                }else {
                    cell.pendingCount.text = "\(pendingCount)"
                }
                return cell
                    
                
                } else {
                return UITableViewCell()
            }
        }else if(indexPath == [0,4]){
            if let cell = tableView.dequeueReusableCell(withIdentifier: "pendingCell") as? PendingSetTableViewCell{
                cell.pendingCount.isHidden = true
                
                cell.titleLabel.text  = "Invite Friend"
                cell.titleLabel.textColor = helping.colors[3]
                return cell;
            } else {
                return UITableViewCell()
            }
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = settings[indexPath.section][indexPath.row]
            return cell;
        }
        
    }
        
        
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        
        var blackLine = UIView(frame: CGRect(x: 0, y: 34, width:
            tableView.bounds.size.width, height: 2))
        blackLine.backgroundColor = UIColor.black
        headerView.addSubview(blackLine)
        
        blackLine = UIView(frame: CGRect(x: 0, y: -4, width:
            tableView.bounds.size.width, height: 2))
        blackLine.backgroundColor = UIColor.black;
        headerView.addSubview(blackLine)
        
        let headerLabel = UILabel(frame: CGRect(x: 8, y: 6, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        
        headerLabel.textColor = UIColor.black
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [0,0]:
            //dismiss(animated: false, completion: nil)
            helping.pushViewControllerAnimated(nav: controller?.navigationController, story: controller?.storyboard, identifier: "Followers")
            moveOutThenDismiss()
            break;
        case [0,1]:
            //dismiss(animated: false, completion: nil)
            helping.pushViewControllerAnimated(nav: controller?.navigationController, story: controller?.storyboard, identifier: "Following")
            moveOutThenDismiss()
            break;
        case [0,2]:
            //dismiss(animated: false, completion: nil)
            helping.pushViewControllerAnimated(nav: controller?.navigationController, story: controller?.storyboard, identifier: "PendingFollowers")
            moveOutThenDismiss()
            break;
        case [0,3]:
            //dismiss(animated: false, completion: nil)
            helping.pushViewControllerAnimated(nav: controller?.navigationController, story: controller?.storyboard, identifier: "MyPosts")
            moveOutThenDismiss()
            break;
        case [0,4]:
            //dismiss(animated: false, completion: nil)
            helping.pushViewControllerAnimated(nav: controller?.navigationController, story: controller?.storyboard, identifier: "InviteFriend")
            moveOutThenDismiss()
            break;
        case [1,0]:
           
            myUserServices.changePassword(view: self)
            break;
        case [1,1]:
           
           myUserServices.logout(view: self)
           break;
        case [2,0]:
            if let url = URL(string: "http://caseycorvino.co") {UIApplication.shared.open(url)}
            break;
        case [2,1]:
            if let url = URL(string: "mailto:thred.master@gmail.com") {UIApplication.shared.open(url)}
            break;
//        case [2,2]:
//            let text = "Check out Thred. http://applink.co".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
//            if let url = URL(string: "sms:&body=\(text)") {UIApplication.shared.open(url, options: [:], completionHandler: nil)}
//            break;
        case [2,2]:
            //dismiss(animated: false, completion: nil)
            helping.pushViewControllerAnimated(nav: controller?.navigationController, story: controller?.storyboard, identifier: "PrivacyPolicy")
            moveOutThenDismiss()
            break;
        case [2,3]:
            helping.pushViewControllerAnimated(nav: controller?.navigationController, story: controller?.storyboard, identifier: "Terms")
            moveOutThenDismiss()
            break;
        case [2,4]:
            //dismiss(animated: false, completion: nil)
            helping.pushViewControllerAnimated(nav: controller?.navigationController, story: controller?.storyboard, identifier: "UserContract")
            moveOutThenDismiss()
            break;
        default:
            break;
        }
    }
    
    @IBAction func hideSettingsView(_ sender: Any) {
        let x: CGFloat = (-250);
        let y  = view.frame.origin.y
        let height = view.frame.size.height
        let width = view.frame.size.width
        controller?.moveBackForMenu()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = CGRect.init(x: x, y: y, width: width, height: height)
            }, completion: { _ in
                self.dismiss(animated: false, completion: nil)
            })
    }
    
    func moveOutThenDismiss(){
        let x: CGFloat = (-250);
        let y  = view.frame.origin.y
        let height = view.frame.size.height
        let width = view.frame.size.width
        controller?.moveBackForMenu()
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect.init(x: x, y: y, width: width, height: height)
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let activeUser = followServices.getActiveUser()
        nameField.text = (activeUser!.name)! as String
        if let rating = activeUser?.getProperty("rating") as? Int{
            rateButton.setTitle("Rating: \(rating)", for: .normal)
        }
        followServices.getPendingFollowerCount(userId: followServices.getActiveUserId()!) { (res: Int) in
            self.pendingCount = res
            
            self.tableView.reloadData()
        }
        
        if((followServices.getActiveUser()?.getProperty("hasInvite") as! Bool) == true){
             settings = [["Followers","Following","Pending Followers","My Posts","Invite Friend"],["Change Password","Logout"],["About","Contact"/*,"Invite Friends"*/,"Privacy Policy","Terms of Services","User Contract"]];
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveIn(){
        let x: CGFloat = (-250)
        let y  = view.frame.origin.y
        let height = view.frame.size.height
        let width = view.frame.size.width
        self.view.frame = CGRect.init(x: x, y: y, width: width, height: height)
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect.init(x: x + 250, y: y, width: width, height: height)
        }
    }
    
    @IBAction func ratingButtonClicked(_ sender: Any) {
        helping.displayAlertOK("Rating", message: "Your rating is the percent of followers that like your posts", view: self)
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
