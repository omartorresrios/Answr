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
    
    var questionsTableViewController: QuestionsTableViewController?
    var imageQuestionTableViewCell: ImageQuestionTableViewCell?
    
    let zoomImageView = UIImageView()
    let blackBackgroundView = UIView()
    let navBarCoverView = UIView()
    let tabBarCoverView = UIView()
    
    var statusImageView: UIImageView?

    override func layoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
        
        questionImageView.isUserInteractionEnabled = true
        questionImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageQuestionTableViewCell?.animate(_:))))
    }
    
    func animateImageView(statusImageView: UIImageView) {
        self.statusImageView = statusImageView
        
        if let startingFrame = statusImageView.superview?.convert(statusImageView.frame, to: nil) {
            
            statusImageView.alpha = 0
            
            blackBackgroundView.frame = (self.superview?.frame)!
            blackBackgroundView.backgroundColor = UIColor.black
            blackBackgroundView.alpha = 0
            superview?.addSubview(blackBackgroundView)
            
            navBarCoverView.frame = CGRect(x: 0, y: 0, width: 1000, height: 20 + 44)
            navBarCoverView.backgroundColor = UIColor.black
            navBarCoverView.alpha = 0
            
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.addSubview(navBarCoverView)
                
                tabBarCoverView.frame = CGRect(x: 0, y: keyWindow.frame.height - 49, width: 1000, height: 49)
                tabBarCoverView.backgroundColor = UIColor.black
                tabBarCoverView.alpha = 0
                keyWindow.addSubview(tabBarCoverView)
            }
            
            zoomImageView.backgroundColor = UIColor.red
            zoomImageView.frame = startingFrame
            zoomImageView.isUserInteractionEnabled = true
            zoomImageView.image = statusImageView.image
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            superview?.addSubview(zoomImageView)
            
            zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageQuestionTableViewCell?.zoomOut(_:))))
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { () -> Void in
                
                let height = ((self.superview?.frame.width)! / startingFrame.width) * startingFrame.height
                
                let y = (self.superview?.frame.height)! / 2 - height / 2
                
                self.zoomImageView.frame = CGRect(x: 0, y: y, width: (self.superview?.frame.width)!, height: height)
                
                self.blackBackgroundView.alpha = 1
                
                self.navBarCoverView.alpha = 1
                
                self.tabBarCoverView.alpha = 1
                
                }, completion: nil)
        }
    }
    
    func zoomOut(_ sender: UITapGestureRecognizer) {
        if let startingFrame = statusImageView!.superview?.convert(statusImageView!.frame, to: nil) {
            
            UIView.animate(withDuration: 0.75, animations: { () -> Void in
                self.zoomImageView.frame = startingFrame
                
                self.blackBackgroundView.alpha = 0
                self.navBarCoverView.alpha = 0
                self.tabBarCoverView.alpha = 0
                
                }, completion: { (didComplete) -> Void in
                    self.zoomImageView.removeFromSuperview()
                    self.blackBackgroundView.removeFromSuperview()
                    self.navBarCoverView.removeFromSuperview()
                    self.tabBarCoverView.removeFromSuperview()
                    self.statusImageView?.alpha = 1
            })
        }
    }
    
    func animate(_ sender: UITapGestureRecognizer) {
        imageQuestionTableViewCell?.animateImageView(statusImageView: questionImageView)
    }
    
    func configureQuestion(question: Question) {
        
        self.imageQuestionTableViewCell = self
        
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
        self.likes.text = "\(question.likes!)"
        
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
