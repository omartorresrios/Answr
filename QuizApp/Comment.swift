//
//  Comment.swift
//  QuizApp
//
//  Created by Omar Torres on 9/23/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
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
    
    init(questionId: String, commentText: String, commenterImageURL: String, firstName: String, key: String = ""){
        
        self.firstName = firstName
        self.questionId = questionId
        self.commentText = commentText
        self.commenterImageURL = commenterImageURL
    }
    
    init(snapshot: FIRDataSnapshot){
        
        self.firstName = snapshot.value!["firstName"] as! String
        self.commenterImageURL = snapshot.value!["commenterImageURL"] as! String
        self.commentText = snapshot.value!["commentText"] as! String
        self.questionId = snapshot.value!["questionId"] as! String
        self.ref = snapshot.ref
        self.key = snapshot.key
    }
    
    
    func toAnyObject() -> [String: AnyObject]{
        
        return ["firstName":firstName, "commentText":commentText,"questionId":questionId,"commenterImageURL":commenterImageURL]
    }
    
}