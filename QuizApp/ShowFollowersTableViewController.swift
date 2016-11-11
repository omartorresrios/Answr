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
    var listFollowers = [NSDictionary?]()
    var user: FIRUser?
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        databaseRef.child("followers").child(self.user!.uid).observe(.childAdded, with: { (snapshot) in
            
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
        let user: NSDictionary?
        let cell = tableView.dequeueReusableCell(withIdentifier: "followersUserCell", for: indexPath) as! FollowersListTableViewCell
        
        user = self.listFollowers[indexPath.row]
        
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

        cell.firstName.text = self.listFollowers[indexPath.row]?["firstName"] as? String
        cell.username.text = self.listFollowers[indexPath.row]?["username"] as? String

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
                let user = listFollowers[indexPath.row]
                showUserProfileVC.otherUser = user
            }
        }
    }
    
}
