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
    var photoURL: String!
    var firstName: String!
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    var points: Int!
    
    init(snapshot: FIRDataSnapshot){
        
        key = snapshot.key
        ref = snapshot.ref
        firstName = (snapshot.value! as! NSDictionary)["firstName"] as! String
        username = (snapshot.value! as! NSDictionary)["username"] as! String
        email = (snapshot.value! as! NSDictionary)["email"] as? String
        photoURL = (snapshot.value! as! NSDictionary)["photoURL"] as! String
        uid = (snapshot.value! as! NSDictionary)["uid"] as? String
        points = (snapshot.value! as! NSDictionary)["points"] as? Int
        
    }
    
    init(username: String, userId: String, photoUrl: String, points: Int){
        self.username = username
        self.uid = userId
        self.photoURL = photoUrl
        self.points = points
    }
}
