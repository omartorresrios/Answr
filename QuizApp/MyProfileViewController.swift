//
//  MyProfileViewController.swift
//  WhatsAppClone
//
//  Created by Omar Torres on 7/13/16.
//  Copyright © 2016 Omar Torres. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MyProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var numberFollowers: UIButton!
    @IBOutlet weak var numberFollowing: UIButton!
    
    var user: User!
    var currentUser:AnyObject?
    var databaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the back button
        self.navigationItem.setHidesBackButton(true, animated: false)

        // Create a button for back to Questions
        let backQuesBtn =  UIButton(type: .custom)
        backQuesBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40) as CGRect
        backQuesBtn.tintColor = UIColor(red: 255/255.0, green: 219/255.0, blue: 81/255.0, alpha: 1.0)
        let img : UIImage = UIImage(named: "Collapse Arrow")!
        backQuesBtn.setImage(img, for: UIControlState.normal)
        backQuesBtn.addTarget(self, action: #selector(comeBackToQuestions), for: .touchUpInside)
        self.navigationItem.titleView = backQuesBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let userRef = FIRDatabase.database().reference().child("Users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            for userInfo in snapshot.children {
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            if let user = self.user {
                
                self.usernameLabel.text = user.username
                self.nameLabel.text = user.firstName
                
                FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        let alertView = SCLAlertView()
                        alertView.showError("OOPS", subTitle: error.localizedDescription)
                        
                    }else{
                        
                        DispatchQueue.main.async(execute: {
                            if let data = imgData {
                                self.userImageView.image = UIImage(data: data)
                            }
                        })
                    }
                })
            }
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // Action for the backToQuestions button
    func comeBackToQuestions(sender:UIButton!) {
        performSegue(withIdentifier: "backToQuestions", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showFollowingTVC" {
            let showFollowingTVC = segue.destination as! ShowFollowingTableViewController
            showFollowingTVC.user = self.currentUser as? FIRUser
            
        } else if segue.identifier == "showFollowersTVC" {
            let showFollowersTVC = segue.destination as! ShowFollowersTableViewController
                showFollowersTVC.user = self.currentUser as? FIRUser
        }
    }
}
