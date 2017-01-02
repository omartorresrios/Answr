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
    @IBOutlet weak var likes: UILabel!
    
    var question: Question!
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
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
    
    func animateImageView(_ statusImageView: UIImageView) {
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
        imageQuestionTableViewCell?.animateImageView(questionImageView)
    }
    
    func configureQuestion(_ question: Question) {
        
        self.imageQuestionTableViewCell = self
        
        self.question = question
        
        if let questionerImgURL = question.questionerImageURL {
            self.userImageView.loadImageUsingCacheWithUrlString(urlString: questionerImgURL)
        }
        
        if let questionImgURL = question.questionImageURL {
            self.questionImageView.loadImageUsingCacheWithUrlString(urlString: questionImgURL)
        }
        
        self.firstNameLabel.text = question.firstName
        self.questionTextLabel.text = question.questionText
        
        if question.numberOfComments.isEmpty {
            self.commentsCounter.isHidden = true
            self.numberOfComments.isHidden = true
        } else {
            self.commentsCounter.isHidden = false
            self.numberOfComments.isHidden = false
            self.commentsCounter.text = "\(question.counterComments!)" + "/"
            self.numberOfComments.text = question.numberOfComments
        }
        
        //TimeStamp
        let timeInterval  = question.timestamp
        
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
