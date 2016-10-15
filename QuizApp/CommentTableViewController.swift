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
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var questionContent: UILabel!
    @IBOutlet weak var counterCommentsLabel: UILabel!
    @IBOutlet weak var numberOfComLabel: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var commentContent: UITextView!
    @IBOutlet weak var numberOfCharLabelCom: UILabel!
    @IBOutlet weak var isSwitched: UISwitch! {
        didSet {
            isSwitched.transform = CGAffineTransform(scaleX: 0.60, y: 0.60)
        }
    }
    @IBOutlet weak var SendCommentBtn: UIButton!
    
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
    
    override func viewDidLayoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change size of UISwitch
        
        // Set the anonymous image to bgImage
        let image: UIImage = UIImage(named: "anonymous.jpg")!
        anonymousImage = UIImageView(image: image)
        
        self.tableView.estimatedRowHeight = 74
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Movements for the limit of answers per question
        counter = selectedQuestion.counterComments
        
        // Allow numberOfComments is optional
        if selectedQuestion.numberOfComments.isEmpty {
            
            counterCommentsLabel.removeFromSuperview()
            numberOfComLabel.removeFromSuperview()
            
        } else {
            numberOfComLabel.text = selectedQuestion.numberOfComments
            counterCommentsLabel.text = "\(selectedQuestion.counterComments!)"
            
            maxNumberComments = Int(selectedQuestion.numberOfComments)!
            
            disabledComments()
        }
    
        configureQuestion()
        
        // Saving the comments
        let commentRef = self.selectedQuestion.ref.child("Comments")
        commentRef.observe(.value, with: { (snapshot) in
            
            var newComments = [Comment]()
            for comment in snapshot.children {
                let newComment = Comment(snapshot: comment as! FIRDataSnapshot)
                newComments.insert(newComment, at: 0)
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
        
        storageRef = FIRStorage.storage().reference(forURL: selectedQuestion.questionerImageURL)
        storageRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
            if error  == nil {
                DispatchQueue.main.async(execute: {
                    if let data = data {
                        self.userImageView.image = UIImage(data: data)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
        
        if (self.selectedQuestion.questionImageURL.isEmpty){
            self.questionImage.removeFromSuperview()
            // Add Top constraint for the questionContent to the userImage
            let questionContentTop = NSLayoutConstraint (item: questionContent, attribute: .top, relatedBy: .equal, toItem: userImageView,
                                                              attribute: .bottom, multiplier: 1.0, constant: 8)
            self.view.addConstraint(questionContentTop)
            
        } else {
            let storageRef2 = FIRStorage.storage().reference(forURL: selectedQuestion.questionImageURL)
            storageRef2.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error  == nil {
                    DispatchQueue.main.async(execute: {
                        if let data = data {
                            self.questionImage.image = UIImage(data: data)
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
            commentContent.isUserInteractionEnabled = false
            SendCommentBtn.isEnabled = false
        }
    }
    
    @IBAction func addCommentAction(_ sender: AnyObject) {
        
        // Clean commentContent after send a comment
        commentContent.text = ""
        
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
        if isSwitched.isOn {
            
			// Reference for the Anonymous Image
            let anonymousImg = anonymousImage.image
            let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.8)
            let anonymousImagePath = "anonymousResponses/\(FIRAuth.auth()!.currentUser!.uid)/anonymousResponserPic.jpg"
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            let anonymousImageRef = storageRef2.reference().child(anonymousImagePath)
            anonymousImageRef.put(anonymousImgData!, metadata: metaData, completion: { (metadata, error) in
                if error == nil {
                    // Create the comment whit the user as anonymous
                    let newComment = Comment(questionId: self.selectedQuestion.questionId, commentText: commentText, commenterImageURL: String(describing: metadata!.downloadURL()!), firstName: self.anonymous, timestamp: NSNumber(value: Date().timeIntervalSince1970))
                    
                    let commentRef = self.selectedQuestion.ref.child("Comments").childByAutoId()
                    
                    commentRef.setValue(newComment.toAnyObject())
                } else {
                    print(error!.localizedDescription)
                }
            })
        } else {
            // Create the comment whit the users data
            let newComment = Comment(questionId: self.selectedQuestion.questionId, commentText: commentText, commenterImageURL: String(describing: FIRAuth.auth()!.currentUser!.photoURL!), firstName: FIRAuth.auth()!.currentUser!.displayName!, timestamp: NSNumber(value: Date().timeIntervalSince1970))
            
            let commentRef = self.selectedQuestion.ref.child("Comments").childByAutoId()
            
            commentRef.setValue(newComment.toAnyObject())
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell

        // Configure the cell...
        
        cell.firstNameLabel.text = commentsArray[(indexPath as NSIndexPath).row].firstName
        cell.commentContent.text = commentsArray[(indexPath as NSIndexPath).row].commentText

        storageRef = FIRStorage.storage().reference(forURL: commentsArray[(indexPath as NSIndexPath).row].commenterImageURL)
        storageRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
            if error  == nil {
                DispatchQueue.main.async(execute: {
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
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainChar:Int = 150 - newLength
        
        numberOfCharLabelCom.text = "\(remainChar)"
        if remainChar == -1 {
            numberOfCharLabelCom.text = "0"
            numberOfCharLabelCom.textColor = UIColor.red
        } else {
            numberOfCharLabelCom.textColor = UIColor.black
            numberOfCharLabelCom.text = "\(remainChar)"
        }
        return (newLength > 150) ? false : true
    }

}
