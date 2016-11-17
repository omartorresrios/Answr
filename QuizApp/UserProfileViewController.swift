//
//  UserProfileViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 10/28/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var backgroundProfile: UIImageView!
    @IBOutlet weak var time: UILabel!
    var currentUser: FIRUser?
    var otherUser: NSDictionary?
    var currentUserData: NSDictionary?
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    override func viewDidLayoutSubviews() {
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the bottom toolbar
        navigationController?.isToolbarHidden = true
        
        backProf()
        
        // Referencing to currentUser
        databaseRef.child("Users").child(self.currentUser!.uid).observe(.value, with: { (snapshot) in
            
            self.currentUserData = snapshot.value as? NSDictionary
            self.currentUserData?.setValue(self.currentUser!.uid, forKey: "uid")
            
            }) { (error) in
                print(error.localizedDescription)
        }
        
        // Referencing to otherUser
        databaseRef.child("Users").child(self.otherUser!["uid"] as! String).observe(.value, with: { (snapshot) in
            
            let uid = self.otherUser?["uid"] as! String
            self.otherUser = snapshot.value as? NSDictionary
            self.otherUser?.setValue(uid, forKey: "uid")
            
            }) { (error) in
                print(error.localizedDescription)
        }
        
        // Check if currentUser is following otherUser
        databaseRef.child("following").child(self.currentUser!.uid).child(self.otherUser?["uid"] as! String).observe(.value, with: { (snapshot) in
            
            if(snapshot.exists()) {
                self.followButton.setTitle("Unfollow", for: .normal)
            } else {
                self.followButton.setTitle("Follow", for: .normal)
            }
            
            }) { (error) in
                print(error.localizedDescription)
        }
        
        // Show the otherUser info
        self.userName.text = self.otherUser?["firstName"] as? String
        
        let otherUserImgURL = self.otherUser?["photoURL"] as? String
        storageRef.reference(forURL: otherUserImgURL!).data(withMaxSize: 1 * 1024 * 1024) { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.userImage.image = UIImage(data: data)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func backProf() {
        
        //Convert to Date
        let date = Date()
        
        //Date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh a"
        
        // hh for hour mm for minutes and a will show you AM or PM
        let str = dateFormatter.string(from: date)
        
        // Sperate str by space i.e. you will get time and AM/PM at index 0 and 1 respectively
        var array = str.components(separatedBy: " ")
        
        // Now you can check it by 12. If < 12 means Its morning > 12 means its evening or night
        
        let timeInHour = array[0]
        let am_pm = array[1]
        
        if Int(timeInHour)! < 12 && (am_pm == "AM") {
            time.text = "Good morning"
            backgroundProfile.image = UIImage(named: "morning")
        }
        else if Int(timeInHour)! <= 4 && (am_pm == "PM") {
            time.text = "Good afternoon"
            backgroundProfile.image = UIImage(named: "afternoon")
        }
        else if Int(timeInHour)! > 4 && (am_pm == "PM") {
            time.text = "Good night"
            backgroundProfile.image = UIImage(named: "night")
        }
        
    }
    
    @IBAction func didTapFollow(_ sender: AnyObject) {
        
        // Reference for the followers list
        let followersRef = "followers/\(self.otherUser?["uid"] as! String)/\(self.currentUserData?["uid"] as! String)"
        
        // Reference for the following list
        let followingRef = "following/" + (self.currentUserData?["uid"] as! String) + "/" + (self.otherUser?["uid"] as! String)
        
        if self.followButton.titleLabel?.text == "Follow" {
            
            let followersData = ["uid": self.currentUserData?["uid"] as! String,
                                "firstName": self.currentUserData?["firstName"] as! String,
                                "username": self.currentUserData?["username"] as! String,
                                "photoURL": "\(self.currentUserData!["photoURL"]!)"]
            
            let followingData = ["uid": self.otherUser?["uid"] as! String,
                                 "firstName": self.otherUser?["firstName"] as! String,
                                 "username": self.otherUser?["username"] as! String,
                                 "photoURL": "\(self.otherUser!["photoURL"]!)"]
            
            let childUpdates = [followersRef: followersData,
                                followingRef: followingData]
            
            databaseRef.updateChildValues(childUpdates)
            
            // Counting and saving the number of followings and followers
            let followersCount: Int?
            let followingCount: Int?
            
            if self.otherUser?["followersCount"] == nil {
                followersCount = 1
            } else {
                followersCount = self.otherUser?["followersCount"] as! Int + 1
            }
            
            if self.currentUserData?["followingCount"] == nil {
                followingCount = 1
            } else {
                followingCount = self.currentUserData?["followingCount"] as! Int + 1
            }
            
            // Saving the value of counters into followingCount field in User's Firebase node
            databaseRef.child("Users").child(self.currentUserData?["uid"] as! String).child("followingCount").setValue(followingCount)
            
            databaseRef.child("Users").child(self.otherUser?["uid"] as! String).child("followersCount").setValue(followersCount!)
            
        } else {
            // Decrease the number of followings for the currentUser
            databaseRef.child("Users").child(self.currentUserData?["uid"] as! String).child("followingCount").setValue(self.currentUserData!["followingCount"] as! Int - 1)
            
            // Decrease the number of followrs for the otherUser
            databaseRef.child("Users").child(self.otherUser?["uid"] as! String).child("followersCount").setValue(self.otherUser!["followersCount"] as! Int - 1)
            
            // Reference for the followers list
            let followersRef = "followers/\(self.otherUser?["uid"] as! String)/\(self.currentUserData?["uid"] as! String)"
            
            // Reference for the following list
            let followingRef = "following/" + (self.currentUserData?["uid"] as! String) + "/" + (self.otherUser?["uid"] as! String)
            
            // Deleting the following and followers nodes
            let childUpdates = [followingRef: NSNull(), followersRef: NSNull()]
            databaseRef.updateChildValues(childUpdates)
            
        }
    }
}
