//
//  CommentViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 10/20/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Firebase

class CommentViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableviewComment: UITableView!
    @IBOutlet weak var commentContent: UITextView!
    @IBOutlet weak var numberOfCharLabelCom: UILabel!
    @IBOutlet weak var isSwitched: UISwitch! {
        didSet {
            isSwitched.transform = CGAffineTransform(scaleX: 0.60, y: 0.60)
        }
    }
    @IBOutlet weak var SendCommentBtn: UIButton!
    @IBOutlet weak var counterCommentsLabel: UILabel!
    @IBOutlet weak var numberOfComLabel: UILabel!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!

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
        
        // Allow numberOfComments is optional
        if selectedQuestion.numberOfComments.isEmpty == false {
            // Put to front the topView
            self.view.bringSubview(toFront: topView)
            // Put all Firebase data on labels
            numberOfComLabel.text = selectedQuestion.numberOfComments
            counterCommentsLabel.text = "\(selectedQuestion.counterComments!)" + "/"
            
            maxNumberComments = Int(selectedQuestion.numberOfComments)!
            
            disabledComments()
        }
        
        // Hide the bottom toolbar
        navigationController?.isToolbarHidden = true
        
        // Set the anonymous image to bgImage
        let image: UIImage = UIImage(named: "anonymous.jpg")!
        anonymousImage = UIImageView(image: image)
        
        if selectedQuestion.questionImageURL.isEmpty {
            self.tableviewComment.estimatedRowHeight = 156
            self.tableviewComment.rowHeight = UITableViewAutomaticDimension
        } else {
            self.tableviewComment.estimatedRowHeight = 323
            self.tableviewComment.rowHeight = UITableViewAutomaticDimension
        }
        
        // Movements for the limit of answers per question
        counter = selectedQuestion.counterComments
        
        // Saving the comments
        let commentRef = self.selectedQuestion.ref.child("Comments")
        commentRef.observe(.value, with: { (snapshot) in
            
            var newComments = [Comment]()
            for comment in snapshot.children {
                let newComment = Comment(snapshot: comment as! FIRDataSnapshot)
                newComments.insert(newComment, at: 0)
            }
            self.commentsArray = newComments
            self.tableviewComment.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // Disabled commentContent and sendButton when comments counter is equal to number of commments
    func disabledComments() {
        if counter == maxNumberComments {
            commentContent.isUserInteractionEnabled = false
            SendCommentBtn.isEnabled = false
            isSwitched.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.showOrHideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.showOrHideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func showOrHideKeyboard(notification: NSNotification) {
        if let keyboardInfo: Dictionary = notification.userInfo {
            if notification.name == NSNotification.Name.UIKeyboardWillShow {
                UIView.animate(withDuration: 1, animations: { () in
                    self.constraintToBottom.constant = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
                    self.view.layoutIfNeeded()
                }) { (completed: Bool) -> Void in
                    // move to the last comment
                    self.moveToLastMessage()
                }
            } else if notification.name == NSNotification.Name.UIKeyboardWillHide {
                UIView.animate(withDuration: 1, animations: { () in
                    self.constraintToBottom.constant = 0
                    self.view.layoutIfNeeded()
                }) { (completed: Bool) -> Void in
                    // move to the last comment
                    self.moveToLastMessage()
                }
            }
        }
    }
    
    func moveToLastMessage() {
        if self.tableviewComment.contentSize.height > self.tableviewComment.frame.height {
            let contentOfSet = CGPoint(x: 0, y: self.tableviewComment.contentSize.height - self.tableviewComment.frame.height)
            self.tableviewComment.setContentOffset(contentOfSet, animated: true)
        }
    }

    @IBAction func addCommentAction(_ sender: AnyObject) {
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
        
        // Clean commentContent after send a comment
        commentContent.text = ""
    }
    
    
    // MARK: - TextView and TextField methods
    
    // TextField delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Limit characters for comments
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainChar:Int = 150 - newLength
        
        if remainChar > 20 {
            numberOfCharLabelCom.textColor = UIColor.black
        }
        if remainChar <= 20 {
            numberOfCharLabelCom.textColor = UIColor.orange
        }
        if remainChar <= 10 {
            numberOfCharLabelCom.textColor = UIColor.red
        }
        if remainChar == -1 {
            numberOfCharLabelCom.text = "0"
        }

        numberOfCharLabelCom.text = "\(remainChar)"
        
        return (newLength > 150) ? false : true
    }
}

// MARK: - Table view data source

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return commentsArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! QuestionTableViewCell
            
            storageRef = FIRStorage.storage().reference(forURL: selectedQuestion.questionerImageURL)
            storageRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error  == nil {
                    DispatchQueue.main.async(execute: {
                        if let data = data {
                            cell.userImageView.image = UIImage(data: data)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            cell.firstName.text = selectedQuestion.firstName
            
            if self.selectedQuestion.questionImageURL.isEmpty {
                // Add Top constraint for questionContent to userImage
                let questionContenTop = NSLayoutConstraint (item: cell.questionContent, attribute: .top, relatedBy: .equal, toItem: cell.userImageView, attribute: .bottom, multiplier: 1.0, constant: 8)
                cell.contentView.addConstraint(questionContenTop)
                
            } else {
                let storageRef2 = FIRStorage.storage().reference(forURL: selectedQuestion.questionImageURL)
                storageRef2.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                    if error  == nil {
                        DispatchQueue.main.async(execute: {
                            if let data = data {
                                cell.questionImage.image = UIImage(data: data)
                            }
                        })
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
            
            cell.questionContent.text = selectedQuestion.questionText
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
            
            cell.firstNameLabel.text = commentsArray[(indexPath as NSIndexPath).row - 1].firstName
            cell.commentContent.text = commentsArray[(indexPath as NSIndexPath).row - 1].commentText
            
            storageRef = FIRStorage.storage().reference(forURL: commentsArray[(indexPath as NSIndexPath).row - 1].commenterImageURL)
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
    }
}
