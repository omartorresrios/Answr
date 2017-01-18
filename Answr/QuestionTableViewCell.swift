//
//  QuestionTableViewCell.swift
//  QuizApp
//
//  Created by Omar Torres on 10/20/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var questionContent: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    
    var question: Question!
    var questionKey: String!
    var tapAction: ((UITableViewCell) -> Void)?
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorageReference!
    
    override func layoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
    }
    
    func configureQuestion(_ question: Question) {
        self.question = question
        
        // Referencing to question
        let questionRef = databaseRef.child("Questions").queryOrdered(byChild: "questionId").queryEqual(toValue: question.questionId)
        questionRef.observe(.childAdded, with: { (snapshotQ) in
            self.questionKey = snapshotQ.key            
            
            // Check if the currentUser liked the question
            let likeRef = self.databaseRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).child("Likes").child(self.questionKey)
            likeRef.observe(.value, with: { (snapshot) in
                if (snapshot.exists()) {
                    // currentUser liked for the question
                    self.likesButton.setImage(UIImage(named: "choclo1"), for: .normal)
                } else {
                    // currentUser hasn't liked for the question... yet
                    self.likesButton.setImage(UIImage(named: "choclo"), for: .normal)
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if let questionerImgURL = question.questionerImageURL {
            self.userImageView.loadImageUsingCacheWithUrlString(urlString: questionerImgURL)
        }
        
        self.firstName.text = question.firstName
        
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
        
        if question.questionImageURL.isEmpty {
            // Add Top constraint for questionContent to userImage
            let questionContenTop = NSLayoutConstraint (item: self.questionContent, attribute: .top, relatedBy: .equal, toItem: self.userImageView, attribute: .bottom, multiplier: 1.0, constant: 8)
            self.contentView.addConstraint(questionContenTop)
            
        } else {
            if let questionImgURL = question.questionImageURL {
                self.questionImage.loadImageUsingCacheWithUrlString(urlString: questionImgURL)
            }
        }
        
        self.questionContent.text = question.questionText
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeTapped(_ sender: AnyObject) {
        tapAction?(self)
    }
}
