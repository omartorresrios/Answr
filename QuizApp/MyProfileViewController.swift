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
        
        UIApplication.shared.isStatusBarHidden = false
        
        self.tabBarController?.tabBar.isHidden = true
        
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
        
        self.currentUser = FIRAuth.auth()?.currentUser

        self.databaseRef.child("Users").child(self.currentUser!.uid).observe(.value, with: { (snapshot) in
            
            let snapshot = snapshot.value as! [String: AnyObject]
            self.nameLabel.text = snapshot["firstName"] as? String
            self.usernameLabel.text = snapshot["username"] as? String
            
            if let user = self.currentUser {
                if user.photoURL != nil {
                    let databasePhotoURL = snapshot["photoURL"] as! String
                    DispatchQueue.main.async {
                        if let data = try? Data(contentsOf: URL(string: databasePhotoURL)!) {
                            self.userImageView!.image = UIImage.init(data: data)
                        }
                    }
                } else {
                    //No user is signed in
                }
            }
            
            if(snapshot["followersCount"] !== nil) {
                self.numberFollowers.setTitle("\(snapshot["followersCount"]!)", for: .normal)
            }
            
            if(snapshot["followingCount"] !== nil){
                self.numberFollowing.setTitle("\(snapshot["followingCount"]!)", for: .normal)
            }
        })
    }
    
    // Customize properties for userImageView
    internal func setProfilePicture(_ imageView: UIImageView, imageToSet: UIImage) {
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.masksToBounds = true
        imageView.image = imageToSet
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // Action for the backToQuestions button
    func comeBackToQuestions(_ sender: UIButton!) {
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        self.navigationController!.view.layer.add(transition, forKey: nil)
        self.navigationController!.isNavigationBarHidden = false
        self.navigationController!.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popToRootViewController(animated: true)
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
