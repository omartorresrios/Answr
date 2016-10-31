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
    var userUid: String!
    var firstName: String!
    var questionId: String!
    var questionText: String!
    var questionImageURL: String!
    var questionerImageURL: String!
    var numberOfComments: String!
    var counterComments: Int!
    var timestamp: NSNumber!
    

    init(userUid: String, questionId: String, questionText: String, questionImageURL: String, questionerImageURL: String, firstName: String, numberOfComments: String, timestamp: NSNumber, counterComments: Int = 0, key: String = ""){
        
        self.userUid = userUid
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
                
        firstName = (snapshot.value! as! NSDictionary)["firstName"] as! String
        questionerImageURL = (snapshot.value! as! NSDictionary)["questionerImageURL"] as! String
        questionText = (snapshot.value! as! NSDictionary)["questionText"] as! String
        questionImageURL = (snapshot.value! as! NSDictionary)["questionImageURL"] as! String
        userUid = (snapshot.value! as! NSDictionary)["userUid"] as! String
        questionId = (snapshot.value! as! NSDictionary)["questionId"] as! String
        numberOfComments = (snapshot.value! as! NSDictionary)["numberOfComments"] as! String
        counterComments = (snapshot.value! as! NSDictionary)["counterComments"] as! Int
        timestamp = (snapshot.value! as! NSDictionary)["timestamp"] as! NSNumber
        ref = snapshot.ref
        key = snapshot.key
        
    }
    
    
    func toAnyObject() -> [String: AnyObject]{
        
        return ["firstName":firstName as AnyObject, "userUid":userUid as AnyObject, "questionText":questionText as AnyObject,"questionId":questionId as AnyObject,"questionerImageURL":questionerImageURL as AnyObject,"questionImageURL":questionImageURL as AnyObject, "numberOfComments":numberOfComments as AnyObject,"counterComments":counterComments as AnyObject,"timestamp":timestamp]
    }

}
