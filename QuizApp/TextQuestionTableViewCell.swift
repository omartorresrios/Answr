//
//  TextQuestionTableViewCell.swift
//  QuizApp
//
//  Created by Omar Torres on 9/17/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import JDStatusBarNotification

class TextQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentsCounter: UILabel!
    @IBOutlet weak var numberOfComments: UILabel!
    @IBOutlet weak var timestamp: UILabel!    
    @IBOutlet weak var likes: UILabel!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    var question: Question!
    
    func showMessage(_ sender: UITapGestureRecognizer) {
        
        //Removing the "/" character of numberOfComments
        var newNumberOfComments = numberOfComments.text!
        newNumberOfComments = newNumberOfComments.replacingOccurrences(of: "/", with: "")
        
        //Showing message with number of comments and counter at the top of the view
        let message = commentsCounter.text! + " de " + newNumberOfComments + " respuestas!"
        JDStatusBarNotification.show(withStatus: message, dismissAfter: 3.0, styleName: JDStatusBarStyleDark)
    }
    
    override func layoutSubviews() {
        // UI for user image
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
        
        // UI for numberOfComments and counter
        numberOfComments.isUserInteractionEnabled = true
        numberOfComments.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TextQuestionTableViewCell.showMessage(_:))))
        
        commentsCounter.isUserInteractionEnabled = true
        commentsCounter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TextQuestionTableViewCell.showMessage(_:))))
    }
    
    
    func configureQuestion(_ question: Question) {
                
        self.question = question
        
        if let questionerImgURL = question.questionerImageURL {
            self.userImageView.loadImageUsingCacheWithUrlString(urlString: questionerImgURL)
        }
        
        self.firstNameLabel.text = question.firstName
        self.questionTextLabel.text = question.questionText
        
        if question.numberOfComments.isEmpty {
            self.commentsCounter.isHidden = true
            self.numberOfComments.isHidden = true
        } else {
            self.commentsCounter.isHidden = false
            self.numberOfComments.isHidden = false
                        
            // Put data into labels
            self.commentsCounter.text = " " + "\(question.counterComments!)"
            self.numberOfComments.text = "/" + question.numberOfComments + " "
        }
        
        //TimeStamp
        let timeInterval = question.timestamp
        
        //Convert to Date
        let date = Date(timeIntervalSince1970: timeInterval as! TimeInterval)
        
        //Date formatting
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        
        let elapsedTimeInSeconds = Date().timeIntervalSince(date as Date)
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "dd/MM/yy"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEE"
        } else {
            dateFormatter.dateFormat = "HH:mm:a"
        }
        
        let dateString = dateFormatter.string(from: date as Date)
        
        self.timestamp.text = dateString
        
        self.likes.text = "\(question.likes!)"
        
        // Hiding the likes label
        if question.likes == 0 {
            self.likes.isHidden = true
        } else {
            self.likes.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
