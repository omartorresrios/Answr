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
    fileprivate func saveInfo(_ user: FIRUser!, username: String, firstName: String, password: String){
        
        let userInfo = ["firstName": firstName, "email": user.email!, "username": username, "uid": user.uid, "photoURL": String(describing: user.photoURL!), "points": 0] as [String : Any]
        
        let userRef = databaseRef.child("Users").child(user.uid)
        
        userRef.setValue(userInfo)
        
        signIn(user.email!, password: password)
    }
    
    // 4 - We sign in the User
    func signIn(_ email: String, password: String){
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                
                if let user = user {
                    
                    print("\(user.displayName!) has signed in successfuly")
                    
                    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logUser()
                }
                
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "theChange"), object: nil)                
            }
        })
        
    }
    
    // 1 - We create firstly a New User
    func signUp(_ email: String, firstName:String, username: String, password: String, data: Data!){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                self.setUserInfo(user, username: username, firstName: firstName, password: password, data: data)
            } else {
                DispatchQueue.main.async(execute: {
                    print(error!.localizedDescription)
                })
            }
        })
        
    }
    
    func resetPassword(_ email: String){
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    let alertView =  SCLAlertView()
                    
                    alertView.showSuccess("👌", subTitle: "Te hemos enviado un correo a \(email) para que puedas cambiar tu contraseña.")
                })
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    // 2 - We set the User Info
    fileprivate func setUserInfo(_ user: FIRUser!, username: String, firstName: String, password: String, data: Data!){
        
        let imagePath = "profileImages/\(user.uid)/userPic.jpg"
       
        let imageRef = storageRef.child(imagePath)
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.put(data, metadata: metadata) { (metadata, error) in
            if error == nil {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = firstName
                
                if let photoURL = metadata!.downloadURL(){
                    changeRequest.photoURL = photoURL
                }
                
                changeRequest.commitChanges(completion: { (error) in
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
