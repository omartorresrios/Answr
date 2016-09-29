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
    
    var databaseRef: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    
    var commentsArray = [Comment]()
    var selectedQuestion: Question!
    var counter: Int = 0
    var conditionalCounter: Int = 0
    var otherConditional: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        counter = selectedQuestion.counterComments
        
        self.tableView.estimatedRowHeight = 123
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        numberOfComLabel.text = selectedQuestion.numberOfComments
        counterCommentsLabel.text = "\(selectedQuestion.counterComments)"
        
        otherConditional = Int(selectedQuestion.numberOfComments)!
        
        configureQuestion()
        
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
    
    @IBAction func addCommentAction(sender: AnyObject) {
        
        conditionalCounter = counter
        
        if conditionalCounter < otherConditional {
            counter += 1
            selectedQuestion.ref.child("counterComments").setValue(counter)
            counterCommentsLabel.text = "\(counter)"
            
            if counter == otherConditional {
                commentContent.userInteractionEnabled = false
                SendCommentBtn.enabled = false
            }
            
        }
        
        var commentText: String!
        if let text: String = commentContent.text {
            commentText = text
        } else {
            commentText = ""
        }
        
        let newComment = Comment(questionId: self.selectedQuestion.questionId, commentText: commentText, commenterImageURL: String(FIRAuth.auth()!.currentUser!.photoURL!), firstName: FIRAuth.auth()!.currentUser!.displayName!)
        
        let commentRef = self.selectedQuestion.ref.child("Comments").childByAutoId()
        
        commentRef.setValue(newComment.toAnyObject())
        
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