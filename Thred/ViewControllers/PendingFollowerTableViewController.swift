//
//  PendingFollowerTableViewController.swift
//  Thred
//
//  Created by Thred. on 12/26/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class PendingFollowerTableViewController: UITableViewController {

    var results:[BackendlessUser] = [];
    
    var pFollowCount = 0;
    var offset = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(results.count == 0){
            return 1;
        }
        return results.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(results.count == 0){
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Pending Followers"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFollowerCell", for: indexPath) as! PendingFollowerTableViewCell
        cell.user = results[indexPath.row];
        cell.userNameTextField?.text = (cell.user?.name)! as String
        cell.acceptButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(self.accceptButtonClicked(sender:)), for: .touchUpInside)
        cell.declineButton.tag = indexPath.row
        cell.declineButton.addTarget(self, action: #selector(self.declineButtonClicked(sender:)), for: .touchUpInside)
        return cell
    }
 
    @objc func accceptButtonClicked(sender: UIButton?) {
        followServices.acceptFollower(userId: results[(sender?.tag)!].objectId! as String, view: self, completionHandler: {(success: Bool) in
            if(success){
                self.results.remove(at: (sender?.tag)!)
                self.pFollowCount -= 1
                self.tableView.reloadData()
            }
        })
        
    }
    
    
    @objc func declineButtonClicked(sender: UIButton?) {
       
        let alert = UIAlertController(title: "Decline Follower?", message: "Are you sure you want to decline this follower?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
        alert.addAction((UIAlertAction(title: "Decline", style: .destructive, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            followServices.declineFollower(userId: self.results[(sender?.tag)!].objectId! as String, view: self, completionHandler: {(success: Bool) in
                if(success){
                    self.results.remove(at: (sender?.tag)!)
                    self.pFollowCount -= 1
                    
                    self.tableView.reloadData()
                }
            })
        })))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func load(){
        UIApplication.shared.beginIgnoringInteractionEvents()
        offset = 0;
        followServices.getPendingFollowerCount(userId: followServices.getActiveUserId()!) { (count: Int) in
            self.pFollowCount = count;
            if count > 0 {
                followServices.retrievePendingFollowers(offset: self.offset, view: self, completionHandler: { (users: [BackendlessUser]) in
                    self.results = users;
                    self.tableView.reloadData()
                    self.offset += 30;
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            
        }
    }
    
    var loading = false;
    func loadMore(){
        //UIApplication.shared.beginIgnoringInteractionEvents()
        if self.pFollowCount > self.results.count {
            loading = true;
            print("going to load more")
            followServices.retrievePendingFollowers(offset: self.offset, view: self, completionHandler: { (users: [BackendlessUser]) in
                self.results += users;
                self.tableView.reloadData()
                self.offset += 30;
                self.loading = false;
                // UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            
                loadMore()
            
        }
    }

}



















