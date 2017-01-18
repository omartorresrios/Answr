//
//  Comment.swift
//  QuizApp
//
//  Created by Omar Torres on 9/23/16.
//  Copyright © 2016 Omar Torres. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Comment {
    var ref: FIRDatabaseReference!
    var key: String!
    var firstName: String!
    var questionId: String!
    var commentText: String!
    var commenterImageURL: String!
    var timestamp: NSNumber!
    
    init(questionId: String, commentText: String, commenterImageURL: String, firstName: String, timestamp: NSNumber, key: String = ""){
        
        self.firstName = firstName
        self.questionId = questionId
        self.commentText = commentText
        self.commenterImageURL = commenterImageURL
        self.timestamp = timestamp
    }
    
    init(snapshot: FIRDataSnapshot){
        
        firstName = (snapshot.value! as! NSDictionary)["firstName"] as! String
        commenterImageURL = (snapshot.value! as! NSDictionary)["commenterImageURL"] as! String
        commentText = (snapshot.value! as! NSDictionary)["commentText"] as! String
        questionId = (snapshot.value! as! NSDictionary)["questionId"] as! String
        timestamp = (snapshot.value! as! NSDictionary)["timestamp"] as! NSNumber
        ref = snapshot.ref
        key = snapshot.key
    }
    
    
    func toAnyObject() -> [String: AnyObject]{
        
        return ["firstName":firstName as AnyObject, "commentText":commentText as AnyObject,"questionId":questionId as AnyObject,"commenterImageURL":commenterImageURL as AnyObject,"timestamp":timestamp]
    }
    
}
