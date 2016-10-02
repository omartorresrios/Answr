//
//  AuthenticationService.swift
//  WhatsAppClone
//
//  Created by Omar Torres on 7/20/16.
//  Copyright © 2016 Omar Torres. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


struct AuthenticationService {
    
    var databaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        
        return FIRStorage.storage().reference()
    }
    
    // 3 - We save the user info in the Database
    private func saveInfo(user: FIRUser!, username: String, firstName: String, password: String){
        
        let userInfo = ["firstName": firstName, "email": user.email!, "username": username, "uid": user.uid, "photoURL": String(user.photoURL!)]
        
        let userRef = databaseRef.child("Users").child(user.uid)
        
        userRef.setValue(userInfo)
        
        signIn(user.email!, password: password)
    }
    
    // 4 - We sign in the User
    func signIn(email: String, password: String){
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error == nil {
                
                if let user = user {
                    
                    print("\(user.displayName!) has signed in successfuly")
                    
                    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDel.logUser()
                }
                
            }else {
                
                let alertView =  SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                
            }
        })
        
    }
    
    // 1 - We create firstly a New User
    func signUp(email: String, firstName:String, username: String, password: String, data: NSData!){
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if error == nil {
                self.setUserInfo(user, username: username, firstName: firstName, password: password, data: data)
            } else {
                let alertView =  SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
            }
        })
        
    }
    
    func resetPassword(email: String){
        
        FIRAuth.auth()?.sendPasswordResetWithEmail(email, completion: { (error) in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertView =  SCLAlertView()
                    
                    alertView.showSuccess("Resetting Password", subTitle: "An email containing the different information on how to reset your password has been sent to \(email)")
                })
                
            }else {
                let alertView =  SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
            }
        })
        
    }
    
    // 2 - We set the User Info
    private func setUserInfo(user: FIRUser!, username: String, firstName: String, password: String, data: NSData!){
        
        let imagePath = "profileImage\(user.uid)/userPic.jpg"
       
        let imageRef = storageRef.child(imagePath)
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(data, metadata: metadata) { (metadata, error) in
            if error == nil {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = firstName
                
                if let photoURL = metadata!.downloadURL(){
                    changeRequest.photoURL = photoURL
                }
                
                changeRequest.commitChangesWithCompletion({ (error) in
                    if error == nil {
                        
                        self.saveInfo(user, username: username, firstName: firstName, password: password)
                    }
                    else {
                        
                        let alertView =  SCLAlertView()
                        alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                        
                    }
                    
                })
            }else {
                
                let alertView =  SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                
                
            }
        }
    }
}