//
//  CommentTableViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 9/23/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Firebase

class CommentTableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var questionContent: UILabel!
    @IBOutlet weak var commentContent: UITextView!
    @IBOutlet weak var numberOfCharLabelCom: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var counterCommentsLabel: UILabel!
    @IBOutlet weak var numberOfComLabel: UILabel!
    @IBOutlet weak var SendCommentBtn: UIButton!
    @IBOutlet weak var isSwitched: UISwitch!
    
    var databaseRef: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    
    var commentsArray = [Comment]()
    var selectedQuestion: Question!
    var counter: Int = 0
    var conditionalCounter: Int = 0
    var maxNumberComments: Int = 0
    let anonymous: String = "Anonymous" // Anonymous users name
    var anonymousImage: UIImageView! // Anonymous users image
    
    var storageRef2: FIRStorage!{
        return FIRStorage.storage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.layer.frame.height / 2
        
        // Set the anonymous image to bgImage
        let image: UIImage = UIImage(named: "anonymous.jpg")!
        anonymousImage = UIImageView(image: image)
        
        self.tableView.estimatedRowHeight = 123
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Movements for the limit of answers per question
        counter = selectedQuestion.counterComments
        
        // Allow numberOfComments is optional
        if selectedQuestion.numberOfComments.isEmpty {
            
            counterCommentsLabel.removeFromSuperview()
            numberOfComLabel.removeFromSuperview()
            
        } else {
            numberOfComLabel.text = selectedQuestion.numberOfComments
            counterCommentsLabel.text = "\(selectedQuestion.counterComments)"
            
            maxNumberComments = Int(selectedQuestion.numberOfComments)!
            
            disabledComments()
        }
    
        configureQuestion()
        
        // Saving the comments
        let commentRef = self.selectedQuestion.ref.child("Comments")
        commentRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            var newComments = [Comment]()
            for comment in snapshot.children {
                let newComment = Comment(snapshot: comment as! FIRDataSnapshot)
                newComments.insert(newComment, atIndex: 0)
            }
            self.commentsArray = newComments
            self.tableView.reloadData()
            
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    //Retrieve Question data
    func configureQuestion() {
        firstName.text = selectedQuestion.firstName
        questionContent.text = selectedQuestion.questionText
        
        storageRef = FIRStorage.storage().referenceForURL(selectedQuestion.questionerImageURL)
        storageRef.dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
            if error  == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    if let data = data {
                        self.userImageView.image = UIImage(data: data)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
        
        if (self.selectedQuestion.questionImageURL.isEmpty){
            self.questionImageView.removeFromSuperview()
            // Add constraints for the name and question
            let constraintDataPlayWidth = NSLayoutConstraint (item: firstName, attribute: .Top, relatedBy: .Equal, toItem: viewMain,
                                                                attribute: .Top, multiplier: 1.0, constant: 0)
            self.view.addConstraint(constraintDataPlayWidth)
            
        } else {
            let storageRef2 = FIRStorage.storage().referenceForURL(selectedQuestion.questionImageURL)
            storageRef2.dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
                if error  == nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        if let data = data {
                            self.questionImageView.image = UIImage(data: data)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    // Disabled commentContent and sendButton when comments counter is equal to number of commments
    func disabledComments() {
        if counter == maxNumberComments {
            commentContent.userInteractionEnabled = false
            SendCommentBtn.enabled = false
        }
    }
    
    @IBAction func addCommentAction(sender: AnyObject) {
        
        // Process counter
        conditionalCounter = counter
        
        if conditionalCounter < maxNumberComments {
            counter += 1
            selectedQuestion.ref.child("counterComments").setValue(counter)
            counterCommentsLabel.text = "\(counter)"
            disabledComments()
        }
        
        var commentText: String!
        if let text: String = commentContent.text {
            commentText = text
        } else {
            commentText = ""
        }
        
        // Its anonymous or not
        if isSwitched.on {
            
            // Reference for the Anonymous Image
            let anonymousImg = anonymousImage.image
            let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.8)
            let anonymousImagePath = "anonymousResponses/\(FIRAuth.auth()!.currentUser!.uid)/anonymousResponserPic.jpg"
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            let anonymousImageRef = storageRef2.reference().child(anonymousImagePath)
            anonymousImageRef.putData(anonymousImgData!, metadata: metaData, completion: { (metadata, error) in
                if error == nil {
                    // Create the comment whit the user as anonymous
                    let newComment = Comment(questionId: self.selectedQuestion.questionId, commentText: commentText, commenterImageURL: String(metadata!.downloadURL()!), firstName: self.anonymous, timestamp: NSDate().timeIntervalSince1970)
            
                    let commentRef = self.selectedQuestion.ref.child("Comments").childByAutoId()
            
                    commentRef.setValue(newComment.toAnyObject())
                } else {
                    print(error!.localizedDescription)
                }
            })
        } else {
            // Create the comment whit the users data
            let newComment = Comment(questionId: self.selectedQuestion.questionId, commentText: commentText, commenterImageURL: String(FIRAuth.auth()!.currentUser!.photoURL!), firstName: FIRAuth.auth()!.currentUser!.displayName!, timestamp: NSDate().timeIntervalSince1970)
            
            let commentRef = self.selectedQuestion.ref.child("Comments").childByAutoId()
            
            commentRef.setValue(newComment.toAnyObject())
        }
        
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentTableViewCell

        
        // Configure the cell...
        
        cell.firstNameLabel.text = commentsArray[indexPath.row].firstName
        cell.commentContent.text = commentsArray[indexPath.row].commentText
        
        storageRef = FIRStorage.storage().referenceForURL(commentsArray[indexPath.row].commenterImageURL)
        storageRef.dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
            if error  == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    if let data = data {
                        cell.commenterImageView.image = UIImage(data: data)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
        return cell
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainChar:Int = 150 - newLength
        
        numberOfCharLabelCom.text = "\(remainChar)"
        if remainChar == -1 {
            numberOfCharLabelCom.text = "0"
            numberOfCharLabelCom.textColor = UIColor.redColor()
        } else {
            numberOfCharLabelCom.textColor = UIColor.blackColor()
            numberOfCharLabelCom.text = "\(remainChar)"
        }
        return (newLength > 150) ? false : true
    }

}