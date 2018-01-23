//
//  SearchTableViewController.swift
//  Thred
//
//  Created by Casey Corvino on 12/3/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {

    var results:[BackendlessUser] = [];
    var filteredResults:[BackendlessUser] = [];
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(filteredResults.count == 0){
            return 1
        }else{
            return filteredResults.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if(filteredResults.count == 0){
            //let cell = tableView.dequeueReusableCell(withIdentifier: "noResultsCell", for: indexPath)
            let cell = UITableViewCell();
            
            if(searchBar.text != ""){
            cell.textLabel?.text = "No Results"
            } else {
                cell.textLabel?.text = ""
            }
            
            return cell
         
         }  else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
            cell.user = filteredResults[indexPath.row];
            cell.userNameTextField?.text = (cell.user?.name)! as String
      
            if ((cell.user?.getProperty("rating") as? Int) != nil){
                cell.rating.text = "\((cell.user?.getProperty("rating") as! Int))"
            } else {
                cell.rating.text = ""
            }
            
            if (cell.user?.getProperty("rating") != nil){
                cell.rating.text = cell.user?.getProperty("rating") as? String
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
            return cell
        }
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
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResults = [];
        for user in results{
            if user.name.lowercased.contains(searchText.lowercased())
            {
                filteredResults.append(user);
            }
        }
        tableView.reloadData()
    }
    
    //keyboard dismissed on search clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true);
        followServices.searchForUsers(searchText: searchBar.text!) { (users: [BackendlessUser]?) in
            if users != nil{
                self.results = users!
                self.filteredResults = users!
                self.tableView.reloadData();
            } else {
                self.results = [];
                self.filteredResults = [];
                self.tableView.reloadData();
            }
        }
        
    }
    

}
