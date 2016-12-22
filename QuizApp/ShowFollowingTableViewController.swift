//
//  ShowFollowingTableViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 10/29/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import Firebase

class ShowFollowingTableViewController: UITableViewController {
    
    @IBOutlet var followingTable: UITableView!
    var user: FIRUser?
    var listFollowing = [NSDictionary?]()

    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isStatusBarHidden = false
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        databaseRef.child("following").child(self.user!.uid).queryOrdered(byChild: "firstName").observe(.childAdded, with: { (snapshot) in
            
            let snapshot = snapshot.value as? NSDictionary
            self.listFollowing.append(snapshot)
            self.followingTable.insertRows(at: [IndexPath(row: self.listFollowing.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
            
        }) { (error) in
            print(error.localizedDescription)
        }
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
        return self.listFollowing.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: NSDictionary?
        let cell = tableView.dequeueReusableCell(withIdentifier: "followingUserCell", for: indexPath) as! FollowingsListTableViewCell
        
        user = self.listFollowing[indexPath.row]
        
        if let userImgURL = user?["photoURL"] as? String {
            cell.userImage.loadImageUsingCacheWithUrlString(urlString: userImgURL)
        }

        cell.firstName.text = self.listFollowing[indexPath.row]?["firstName"] as? String
        cell.username.text = self.listFollowing[indexPath.row]?["username"] as? String
        cell.points.text = "\(self.listFollowing[indexPath.row]?["points"] as! Int)"
        
        return cell
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller is MyProfileViewController {
                self.navigationController!.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowUser" {
            let showUserProfileVC = segue.destination as! UserProfileViewController
            showUserProfileVC.currentUser = self.user
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let user = listFollowing[indexPath.row]
                showUserProfileVC.otherUser = user
            }
        }
    }
    
}
