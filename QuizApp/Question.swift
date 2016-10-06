//
//  Question.swift
//  QuizApp
//
//  Created by Omar Torres on 9/17/16.
//  Copyright © 2016 Omar Torres. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Question {
    var ref: FIRDatabaseReference!
    var key: String!
    var username: String!
    var firstName: String!
    var questionId: String!
    var questionText: String!
    var questionImageURL: String!
    var questionerImageURL: String!
    var numberOfComments: String!
    var counterComments: Int!
    var timestamp: NSNumber!
    

    init(username: String, questionId: String, questionText: String, questionImageURL: String, questionerImageURL: String, firstName: String, numberOfComments: String, timestamp: NSNumber, counterComments: Int = 0, key: String = ""){
        
        self.username = username
        self.firstName = firstName
        self.questionId = questionId
        self.questionImageURL = questionImageURL
        self.questionText = questionText
        self.questionerImageURL = questionerImageURL
        self.numberOfComments = numberOfComments
        self.counterComments = counterComments
        self.timestamp = timestamp
        
    }
    
    init(snapshot: FIRDataSnapshot){
        
        self.firstName = snapshot.value!["firstName"] as! String
        self.questionerImageURL = snapshot.value!["questionerImageURL"] as! String
        self.questionText = snapshot.value!["questionText"] as! String
        self.questionImageURL = snapshot.value!["questionImageURL"] as! String
        self.username = snapshot.value!["username"] as! String
        self.questionId = snapshot.value!["questionId"] as! String
        self.numberOfComments = snapshot.value!["numberOfComments"] as! String
        self.counterComments = snapshot.value!["counterComments"] as! Int
        self.timestamp = snapshot.value!["timestamp"] as! NSNumber
        self.ref = snapshot.ref
        self.key = snapshot.key
        
    }
    
    
    func toAnyObject() -> [String: AnyObject]{
        
        return ["firstName":firstName, "username":username, "questionText":questionText,"questionId":questionId,"questionerImageURL":questionerImageURL,"questionImageURL":questionImageURL, "numberOfComments":numberOfComments,"counterComments":counterComments,"timestamp":timestamp]
    }

}