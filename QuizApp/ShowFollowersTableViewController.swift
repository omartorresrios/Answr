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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "followersUserCell", for: indexPath) as! FollowersListTableViewCell

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
    
}
