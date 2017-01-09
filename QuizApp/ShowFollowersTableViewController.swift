//
//  ShowFollowersTableViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 10/29/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import Firebase

class ShowFollowersTableViewController: UITableViewController {

    @IBOutlet var followersTable: UITableView!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    var otherUser: NSDictionary?
    var currentUserData: NSDictionary?
    var listFollowers = [NSDictionary?]()
    var currentUser: FIRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isStatusBarHidden = false
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        databaseRef.child("followers").child(self.currentUser!.uid).observe(.childAdded, with: { (snapshot) in
            
            let snapshot = snapshot.value as? NSDictionary
            self.listFollowers.append(snapshot)
            self.followersTable.insertRows(at: [IndexPath(row: self.listFollowers.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
            
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
        return listFollowers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "followersUserCell", for: indexPath) as! FollowersListTableViewCell
        
        var user: NSDictionary?
        
        user = self.listFollowers[indexPath.row]
        
        if let userImgURL = user?["photoURL"] as? String {
            cell.userImage.loadImageUsingCacheWithUrlString(urlString: userImgURL)
        }

        cell.firstName.text = self.listFollowers[indexPath.row]?["firstName"] as? String
        cell.username.text = self.listFollowers[indexPath.row]?["username"] as? String
        cell.points.text = "\(self.listFollowers[indexPath.row]?["points"] as! Int)"

        
        let butCell = cell.followButton
        
        // Referencing to currentUser
        databaseRef.child("Users").child(self.currentUser!.uid).observe(.value, with: { (snapshot) in
            
            self.currentUserData = snapshot.value as? NSDictionary
            self.currentUserData?.setValue(self.currentUser!.uid, forKey: "uid")
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Referencing to otherUser
        databaseRef.child("Users").child(user?["uid"] as! String).observe(.value, with: { (snapshot) in
            
            let uid = user?["uid"] as! String
            user = snapshot.value as? NSDictionary
            user?.setValue(uid, forKey: "uid")
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Check if currentUser is following otherUser
        databaseRef.child("following").child(self.currentUser!.uid).child(user?["uid"] as! String).observe(.value, with: { (snapshot) in
            
            if(snapshot.exists()) {
                cell.followButton.setTitle("Unfollow", for: .normal)
            } else {
                cell.followButton.setTitle("Follow", for: .normal)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Assign the tap action which will be executed when the user taps the Follow button
        cell.tapAction = { (cell) in
            // Reference for the followers list
            let followersRef = "followers/\(user?["uid"] as! String)/\(self.currentUserData?["uid"] as! String)"
            
            // Reference for the following list
            let followingRef = "following/" + (self.currentUserData?["uid"] as! String) + "/" + (user?["uid"] as! String)
            
            if butCell?.titleLabel?.text == "Follow" {
                
                let followersData = ["uid": self.currentUserData?["uid"] as! String,
                                     "firstName": self.currentUserData?["firstName"] as! String,
                                     "username": self.currentUserData?["username"] as! String,
                                     "points": self.currentUserData?["points"] as! Int,
                                     "photoURL": "\(self.currentUserData!["photoURL"]!)"] as [String : Any]
                
                let followingData = ["uid": user?["uid"] as! String,
                                     "firstName": user?["firstName"] as! String,
                                     "username": user?["username"] as! String,
                                     "points": user?["points"] as! Int,
                                     "photoURL": "\(user!["photoURL"]!)"] as [String : Any]
                
                let childUpdates = [followersRef: followersData,
                                    followingRef: followingData]
                
                self.databaseRef.updateChildValues(childUpdates)
                
                // Counting and saving the number of followings and followers
                let followersCount: Int?
                let followingCount: Int?
                
                if user?["followersCount"] == nil {
                    followersCount = 1
                } else {
                    followersCount = user?["followersCount"] as! Int + 1
                }
                
                if self.currentUserData?["followingCount"] == nil {
                    followingCount = 1
                } else {
                    followingCount = self.currentUserData?["followingCount"] as! Int + 1
                }
                
                // Saving the value of counters into followingCount field in User's Firebase node
                self.databaseRef.child("Users").child(self.currentUserData?["uid"] as! String).child("followingCount").setValue(followingCount)
                
                self.databaseRef.child("Users").child(user?["uid"] as! String).child("followersCount").setValue(followersCount!)
                
            } else {
                // Decrease the number of followings for the currentUser
                self.databaseRef.child("Users").child(self.currentUserData?["uid"] as! String).child("followingCount").setValue(self.currentUserData!["followingCount"] as! Int - 1)
                
                // Decrease the number of followrs for the otherUser
                self.databaseRef.child("Users").child(user?["uid"] as! String).child("followersCount").setValue(user!["followersCount"] as! Int - 1)
                
                // Reference for the followers list
                let followersRef = "followers/\(user?["uid"] as! String)/\(self.currentUserData?["uid"] as! String)"
                
                // Reference for the following list
                let followingRef = "following/" + (self.currentUserData?["uid"] as! String) + "/" + (user?["uid"] as! String)
                
                // Deleting the following and followers nodes
                let childUpdates = [followingRef: NSNull(), followersRef: NSNull()]
                self.databaseRef.updateChildValues(childUpdates)
                
            }
        }
        
        
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
        
        if segue.identifier == "showUserFromFollowers" {
            let showUserProfileVC = segue.destination as! UserProfileViewController
            showUserProfileVC.currentUser = self.currentUser
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let user = listFollowers[indexPath.row]
                showUserProfileVC.otherUser = user
            }
        }
    }
    
}
