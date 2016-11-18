//
//  ImageQuestionTableViewCell.swift
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

class ImageQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionImageView: UIImageView! {
        didSet {
            questionImageView.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentsCounter: UILabel!
    @IBOutlet weak var numberOfComments: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    @IBOutlet weak var likes: UILabel!
    
    var question: Question!
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }

    override func layoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
    }
    
    func configureQuestion(question: Question) {
        
        self.question = question
        
        // Set question's data
        let questionerImgURL = question.questionerImageURL!
        storageRef.reference(forURL: questionerImgURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    if let data = data {
                        self.userImageView.image = UIImage(data: data)
                    }
                })
            }else {
                print(error!.localizedDescription)
            }
        })
        
        let questionImgURL = question.questionImageURL!
        storageRef.reference(forURL: questionImgURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    if let data = data {
                        self.questionImageView.image = UIImage(data: data)
                    }
                })
            }else {
                print(error!.localizedDescription)
            }
        })
        
        self.firstNameLabel.text = question.firstName
        self.questionTextLabel.text = question.questionText
        if question.numberOfComments.isEmpty == false {
            self.commentsCounter.text = "\(question.counterComments!)" + "/"
            self.numberOfComments.text = question.numberOfComments
        }
        self.likes.text = "\(question.likes)"
        
        //TimeStamp
        let timeInterval  = question.timestamp
        
        //Convert to Date
        let date = NSDate(timeIntervalSince1970: timeInterval as! TimeInterval)
        
        //Date formatting
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = NSTimeZone.local
        
        let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
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
        
        // Check if the currentUser liked the question
        let likeRef = databaseRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).child("Likes").child(question.key)
        
        likeRef.observe(.value, with: { (snapshot) in
            if (snapshot.exists()) {
                // currentUser liked for the question
                self.likesImage.image = UIImage(named: "Like-0")
            } else {
                // currentUser hasn't liked for the question... yet
                self.likesImage.image = UIImage(named: "Like")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func likeTapped(_ sender: UITapGestureRecognizer) {
        
        // Counting and saving the number of likes
        if self.likesImage.image == UIImage(named: "Like") {
            let likesCount: Int?
            if question.likes == nil {
                likesCount = 1
            } else {
                likesCount = question.likes + 1
            }
            // Saving the value of likesCount into likes field in Question's Firebase node
            self.databaseRef.child("Questions").child(question.key).child("likes").setValue(likesCount)
            // Saving the question's key in the currentUser's Like subnode as a boolean
            self.databaseRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).child("Likes").child(question.key).setValue(true)
        } else {
            self.databaseRef.child("Questions").child(question.key).child("likes").setValue(question.likes - 1)
            self.databaseRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).child("Likes").child(question.key).removeValue()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // UITapGestureRecognizer is set programatically.
        let tap = UITapGestureRecognizer(target: self, action: #selector(TextQuestionTableViewCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likesImage.addGestureRecognizer(tap)
        likesImage.isUserInteractionEnabled = true
    }
}
