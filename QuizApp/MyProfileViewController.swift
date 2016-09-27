//
//  MyProfileViewController.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/13/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MyProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.layer.frame.width/2
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let userRef = FIRDatabase.database().reference().child("Users").queryOrderedByChild("uid").queryEqualToValue(FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observeEventType(.Value, withBlock: { (snapshot) in
            for userInfo in snapshot.children {
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            if let user = self.user {
                
                self.userEmailLabel.text = user.email
                self.usernameLabel.text = user.username
                
                FIRStorage.storage().referenceForURL(user.photoURL).dataWithMaxSize(1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        let alertView = SCLAlertView()
                        alertView.showError("OOPS", subTitle: error.localizedDescription)
                        
                    }else{
                        
                        dispatch_async(dispatch_get_main_queue(), {
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func logOutAction(sender: AnyObject) {
        /*do {
            try FIRAuth.auth()?.signOut()
            if FIRAuth.auth()?.currentUser == nil {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("start") as! StartViewController
                presentViewController(vc, animated: true, completion: nil)
            }
        } catch let error as NSError {
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }*/

        if FIRAuth.auth()!.currentUser != nil {
            do { // Podríamos obviar esta sentencia do. Averiguar y profundizar bien en esto
                try FIRAuth.auth()?.signOut()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("start") // Podríamos eliminar el StartViewController que se creó
                presentViewController(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                
                let alertView = SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error.localizedDescription)
            }
        }
    }
}
