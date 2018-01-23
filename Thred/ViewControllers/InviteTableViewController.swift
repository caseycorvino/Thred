//
//  InviteTableViewController.swift
//  Thred
//
//  Created by Thred. on 1/23/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

import Contacts

class InviteTableViewController: UITableViewController {

    var contacts: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContacts()
        
        
    }

    func getContacts(){
        let store = CNContactStore()
        
        let keysToFetch: [CNKeyDescriptor] = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]
        
        var allContainers: [CNContainer] = []
        
        do{
            allContainers = try store.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch)
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        contacts = results;
        
        tableView.reloadData()
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
        
        return contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = "\(contacts[indexPath.row].givenName) \(contacts[indexPath.row].familyName)"

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
