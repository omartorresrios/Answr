//
//  User.swift
//
//  Created by Omar Torres on 7/21/16.
//  Copyright © 2016 Omar Torres. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct User {
    
    var username: String!
    var email: String?
    var country: String?
    var photoURL: String!
    var biography: String?
    var firstName: String!
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    
    init(snapshot: FIRDataSnapshot){
        
        key = snapshot.key
        ref = snapshot.ref
        firstName = (snapshot.value! as! NSDictionary)["firstName"] as! String
        username = (snapshot.value! as! NSDictionary)["username"] as! String
        email = (snapshot.value! as! NSDictionary)["email"] as? String
        country = (snapshot.value! as! NSDictionary)["country"] as? String
        biography = (snapshot.value! as! NSDictionary)["biography"] as? String
        photoURL = (snapshot.value! as! NSDictionary)["photoURL"] as! String
        uid = (snapshot.value! as! NSDictionary)["uid"] as? String
        
    }
    
    init(username: String, userId: String, photoUrl: String){
        self.username = username
        self.uid = userId
        self.photoURL = photoUrl
    }
}
