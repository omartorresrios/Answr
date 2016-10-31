//
//  FollowUsersTableViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 10/8/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Firebase
import FirebaseAuth

class FollowUsersTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var followUsersTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var usersArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    var currentUser: FIRUser?
    
    var databaseRef = FIRDatabase.database().reference()
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Busca"
        
        databaseRef.child("Users").queryOrdered(byChild: "firstName").observe(.childAdded, with: { (snapshot) in
            
            let key = snapshot.key
            let snapshot = snapshot.value as? NSDictionary
            snapshot?.setValue(key, forKey: "uid")
            
            if key == self.currentUser?.uid {
                print("Same as currentUser")
            } else {
                self.usersArray.append(snapshot)
                
                // Insert the rows
                self.followUsersTableView.insertRows(at: [IndexPath(row: self.usersArray.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        } else {
            return self.usersArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! FollowUsersTableViewCell
        
        let user: NSDictionary?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = self.usersArray[indexPath.row]
        }
        
        let userImgURL = user?["photoURL"] as? String
        storageRef.reference(forURL: userImgURL!).data(withMaxSize: 1 * 1024 * 1024) { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        cell.userImage.image = UIImage(data: data)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        cell.firstName.text = user?["firstName"] as? String
        cell.username.text = user?["username"] as? String
        
        
        return cell
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func filterContent(searchText: String) {
        self.filteredUsers = self.usersArray.filter{ user in
            let name = user!["firstName"] as? String
            
            return(name?.lowercased().contains(searchText.lowercased()))!
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowUser" {
            let showUserProfileVC = segue.destination as! UserProfileViewController
            showUserProfileVC.currentUser = self.currentUser
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let user = usersArray[indexPath.row]
                showUserProfileVC.otherUser = user
            }
        }
        
        
        if segue.identifier == "showQuestionsTVC" {
            let showFollowUsersTVC = segue.destination as! QuestionsTableViewController
            showFollowUsersTVC.user = self.currentUser
        }
    }
}
