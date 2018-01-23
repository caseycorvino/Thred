//
//  FollowerTableViewController.swift
//  Thred
//
//  Created by Casey Corvino on 12/5/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class FollowerTableViewController: UITableViewController, UISearchBarDelegate{

    var results:[BackendlessUser] = [];
    var filteredResults:[BackendlessUser] = [];
    
    var followCount = 0;
    var offset = 0;
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        load()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(filteredResults.count == 0){
            return 1;
        }
        return filteredResults.count
            
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         if(filteredResults.count == 0){
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Results"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        cell.user = filteredResults[indexPath.row];
        cell.userNameTextField?.text = (cell.user?.name)! as String
        
        if ((cell.user?.getProperty("rating") as? Int) != nil){
            cell.rating.text = "\((cell.user?.getProperty("rating") as! Int))"
        } else {
            cell.rating.text = ""
        }
        
        if(activeUserFollowing.contains((cell.user?.objectId)! as String) || activeUserPendingFollowing.contains((cell.user?.objectId)! as String)){
            helping.setForFollowing(background: cell.followButtonView, button: cell.followButton);
        } else {
            helping.setForNotFollowing(background: cell.followButtonView, button: cell.followButton);
        }
        cell.followButton.tag = indexPath.row
        cell.followButton.addTarget(self, action: #selector(self.followButtonClicked(sender:)), for: .touchUpInside)
        cell.unacceptButton?.tag = indexPath.row
        cell.unacceptButton?.addTarget(self, action: #selector(self.unacceptButtonClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func unacceptButtonClicked(sender: UIButton?) {
        print("Unaccept")
        let alert = UIAlertController(title: "Unaccept Follower?", message: "Are you sure you want to unaccept this follower?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            let cell: UserTableViewCell = self.tableView.cellForRow(at: [0,(sender?.tag)!]) as! UserTableViewCell
            followServices.declineFollower(userId: (cell.user?.objectId)! as String, view: self) { (re:Bool) in
                let resultsInd = helping.userInArray(user: cell.user!, arr: self.results)
                if(resultsInd != -1){
                    self.results.remove(at: resultsInd)
                }
                let filtResultsInd = helping.userInArray(user: cell.user!, arr: self.filteredResults)
                if(filtResultsInd != -1){
                    self.filteredResults.remove(at: filtResultsInd)
                }
                
            }
            alert.dismiss(animated: true, completion: nil)
            
        })))
        alert.addAction((UIAlertAction(title: "No", style: .cancel, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
        self.present(alert, animated: true, completion: nil)
        
    }
    @objc func followButtonClicked(sender: UIButton?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let cell: UserTableViewCell = tableView.cellForRow(at: [0,(sender?.tag)!]) as! UserTableViewCell
        if(activeUserFollowing.contains((cell.user?.objectId)! as String) || activeUserPendingFollowing.contains((cell.user?.objectId)! as String)){
            followServices.unFollowUser(view: self, userId: (cell.user?.objectId)! as String, completionHandler: { (success:Bool) in
                if success{
                    helping.setForNotFollowing(background: cell.followButtonView, button: cell.followButton)
                    var idIndex = helping.stringInArray(str: (cell.user?.objectId)! as String, arr: activeUserFollowing);
                    if(idIndex != -1){
                        activeUserFollowing.remove(at: idIndex)
                    } else {
                        idIndex = helping.stringInArray(str: (cell.user?.objectId)! as String, arr: activeUserPendingFollowing);
                        activeUserPendingFollowing.remove(at: idIndex)
                    }
                }
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        } else {
            followServices.followUser(view: self, userId: (cell.user?.objectId)! as String) { (success:Bool) in
                if success{
                    helping.setForFollowing(background: cell.followButtonView, button: cell.followButton)
                    activeUserPendingFollowing.append((cell.user?.objectId)! as String)
                }
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
    
    //keyboard dismissed on scroll
    override func  scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
       
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == ""){
            filteredResults = results
            tableView.reloadData()
            return
        }
        filteredResults = [];
        for user in results{
            if user.name.lowercased.contains(searchText.lowercased())
            {
                filteredResults.append(user);
            }
        }
        tableView.reloadData()
    }
    
    var oldResults:[BackendlessUser] = []
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func load(){
        UIApplication.shared.beginIgnoringInteractionEvents()
        offset = 0;
        followServices.getFollowerCount(userId: followServices.getActiveUserId()!) { (count: Int) in
            self.followCount = count;
            self.loadFollowers(count: count)
        }
    }
    
    func loadFollowers(count: Int){
        if count > self.results.count {
            followServices.getFollowers( offset: self.offset, userId: followServices.getActiveUserId()!, view: self, completionHandler: { (users: [BackendlessUser]) in
                self.results += users;
                self.filteredResults += users;
                self.offset += users.count;
                self.loadFollowers(count: count)
            })
        } else {
            tableView.reloadData()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    var loading = false;
    func loadMore(){
        loading = true;
        //UIApplication.shared.beginIgnoringInteractionEvents()
            if self.followCount > self.results.count {
                print("Loading More Followers")
                followServices.getFollowers(offset: self.offset, userId: followServices.getActiveUserId()!, view: self, completionHandler: { (users: [BackendlessUser]) in
                    
                    if(users.count > 0){
                    self.results += users;
                    self.filteredResults += users;
                    self.tableView.reloadData()
                    self.offset += users.count;
                    
                    let delayInSeconds = 5.0
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                        self.loading = false;
                    }
                    } else {
                         print("No More Posts")
                    }
                   // UIApplication.shared.endIgnoringInteractionEvents()
                })
            } else{
                print("No More Posts")
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
