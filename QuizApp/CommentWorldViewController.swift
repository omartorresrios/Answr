//
//  CommentWorldViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 19/12/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Firebase
import JDStatusBarNotification

class CommentWorldViewController: UIViewController, UIGestureRecognizerDelegate {

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
    @IBOutlet weak var commentStackView: UIView!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    var commentsArray = [NSDictionary?]()
    var questionArray = [Question]()
    var currentUser: User!
    var selectedQuestion1:Question!
    var question: Question!
    var questionKey1: String!
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
        
        UIApplication.shared.isStatusBarHidden = false
        
        self.tabBarController?.tabBar.isHidden = true
        
        // Hide the bottom toolbar
        navigationController?.isToolbarHidden = true
        
        // Set the anonymous image to bgImage
        let image: UIImage = UIImage(named: "anonymous.jpg")!
        anonymousImage = UIImageView(image: image)
        
        if selectedQuestion1.questionImageURL.isEmpty {
            self.tableviewComment.estimatedRowHeight = 156
            self.tableviewComment.rowHeight = UITableViewAutomaticDimension
        } else {
            self.tableviewComment.estimatedRowHeight = 323
            self.tableviewComment.rowHeight = UITableViewAutomaticDimension
        }
        
        // Movements for the limit of answers per question
        counter =  selectedQuestion1.counterComments
        
        self.hideKeyboardWhenTappedAround()
        
        //        self.databaseRef.child("Questions").child(self.selectedQuestion.key).child("Comments").observe(.value, with: { (snapshot) in
        //            if !snapshot.exists() {
        //                let indexP = [NSIndexPath.init(row: 1, section: 0)]
        //                tableView.deleteRows(at: indexP as [IndexPath], with: .automatic)
        //                //tableView.reloadData()
        //            }
        //        })
        
        // Top border for commentStackView
        let TopBorder = CALayer()
        TopBorder.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(commentStackView.frame.size.width), height: CGFloat(0.5))
        TopBorder.backgroundColor = UIColor.lightGray.cgColor
        commentStackView.layer.addSublayer(TopBorder)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Retrieving the question
        self.fetchQuestion()
        
        // Disabled sendCommentBtn
        SendCommentBtn.isUserInteractionEnabled = false
        SendCommentBtn.setTitleColor(UIColor.darkGray, for: .normal)
        
        // Referencing to currentUser
        let userRef = databaseRef.child("Users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            for userInfo in snapshot.children {
                self.currentUser = User(snapshot: userInfo as! FIRDataSnapshot)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Referencing to question
        let questionRef = databaseRef.child("Questions").queryOrdered(byChild: "questionId").queryEqual(toValue: selectedQuestion1.questionId)
        questionRef.observe(.childAdded, with: { (snapshotQ) in
            print("key: \(snapshotQ.key)")
            self.questionKey1 = snapshotQ.key
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Allow numberOfComments is optional
        if selectedQuestion1.numberOfComments.isEmpty == false {
            
            // Put to front the topView
            self.view.bringSubview(toFront: topView)
            
            // Put all Firebase data on labels
            numberOfComLabel.text =  "/" + selectedQuestion1.numberOfComments + " "
            counterCommentsLabel.text = " " + "\(selectedQuestion1.counterComments!)"
            
            maxNumberComments =  Int(selectedQuestion1.numberOfComments)!
            
            // Check if it show or hide commentStackView
            disabledEnabledCommentStackView()
            
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        if counter != maxNumberComments {
            // UI for commentContent
            commentContent.layer.cornerRadius = commentContent.frame.size.height / 2
            commentContent.clipsToBounds = true
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Retrieving the answers
        self.fetchAnswers()
        
        // Movements for show or hide the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(CommentWorldViewController.showOrHideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentWorldViewController.showOrHideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    fileprivate func fetchQuestion() {
        
        databaseRef.child("Questions").observe(.value, with: { (questions) in
            var newQuestionsArray = [Question]()
            for question in questions.children {
                let newQuestion = Question(snapshot: question as! FIRDataSnapshot)
                
                if newQuestion.questionId == self.selectedQuestion1.questionId {
                    newQuestionsArray.insert(newQuestion, at: 0)
                }
            }
            self.questionArray = newQuestionsArray
            DispatchQueue.main.async {
                self.tableviewComment.reloadData()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func fetchAnswers() {
        self.databaseRef.child("Questions").child(self.questionKey1!).child("Comments").observe(.childAdded, with: { (snapshot) in
            
            let key = snapshot.key
            let snapshot = snapshot.value as? NSDictionary
            snapshot?.setValue(key, forKey: "questionId")
            
            self.commentsArray.insert(snapshot, at: 0)
            
            self.tableviewComment.insertRows(at: [IndexPath(row: self.commentsArray.count, section: 0)], with: UITableViewRowAnimation.automatic)
            
            print("comments: \(self.commentsArray)")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // Disabled/enabled commentStackView according to the counter and number of comments
    func disabledEnabledCommentStackView() {
        if counter == maxNumberComments {
            
            // Remove commentContent, numberOfComLabel and sendButton
            commentStackView.removeFromSuperview()
            
            // Add bottom constraint for tableviewComment to superview
            let tableviewCommentBottom = NSLayoutConstraint (item: tableviewComment, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
            view.addConstraint(tableviewCommentBottom)
            
            // Display UIView from bottom with "No more answers allowed" message
            
            let viewWidth = view.bounds.width
            let viewHeight = view.frame.size.height
            
            let messageView = UIView(frame: CGRect(x: 0, y: viewHeight, width: viewWidth, height: 0))
            messageView.backgroundColor = UIColor(colorLiteralRed: 18/255.0, green: 165/255.0, blue: 244/255.0, alpha: 1)
            
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseIn, animations: {() -> Void in
                messageView.frame = CGRect(x: 0, y: viewHeight - 30, width: viewWidth, height: 30)
                }, completion: {(_ finished: Bool) -> Void in
            })
            
            let messageLabel = UILabel()
            messageLabel.text = "No se permiten más respuestas 😟"
            messageLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
            messageLabel.textColor = UIColor.white
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.clipsToBounds = true
            
            messageView.addSubview(messageLabel)
            
            // ios 9 constraint anchors
            // Need x and y anchors
            messageLabel.centerYAnchor.constraint(equalTo: messageView.centerYAnchor).isActive = true
            messageLabel.centerXAnchor.constraint(equalTo: messageView.centerXAnchor).isActive = true
            
            self.view.addSubview(messageView)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
    
    func animationPoints() {
        GoogleWearAlert.showAlert(title:"+1", UIImage(named: "logo")!, type: .success, duration: 2.0, inViewController: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if !textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            SendCommentBtn.isUserInteractionEnabled = true
            SendCommentBtn.setTitleColor(UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1), for: .normal)
        } else {
            SendCommentBtn.isUserInteractionEnabled = false
            SendCommentBtn.setTitleColor(UIColor.darkGray, for: .normal)
        }
    }
    
    @IBAction func addCommentAction(_ sender: AnyObject) {
        // Process counter
        conditionalCounter = counter
        
        if conditionalCounter < maxNumberComments {
            counter += 1
            selectedQuestion1.ref.child("counterComments").setValue(counter)
            counterCommentsLabel.text = " " + "\(counter)"
            disabledEnabledCommentStackView()
        }
        
        var commentText: String!
        if let text: String = commentContent.text {
            commentText = text
        } else {
            commentText = ""
        }
        
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "logo")
        
        alertView.addButton("\(FIRAuth.auth()!.currentUser!.displayName!)") {
            
            // Reset UI on commentStackView
            self.SendCommentBtn.isUserInteractionEnabled = false
            self.SendCommentBtn.setTitleColor(UIColor.darkGray, for: .normal)
            self.commentContent.text = ""
            
            // Create the comment whit the users data
            let newComment = Comment(questionId: self.selectedQuestion1.questionId, commentText: commentText, commenterImageURL: String(describing: FIRAuth.auth()!.currentUser!.photoURL!), firstName: FIRAuth.auth()!.currentUser!.displayName!, timestamp: NSNumber(value: Date().timeIntervalSince1970))
            
            let commentRef = self.databaseRef.child("Questions").child(self.questionKey1!).child("Comments").childByAutoId()
            
            commentRef.setValue(newComment.toAnyObject())
            
            // Saving the points for the currentUser
            self.savePoints()
            
            // User geat a point
            self.animationPoints()
            
        }
        
        alertView.addButton("Anónimo") {
         
            // Reset UI on commentStackView
            self.SendCommentBtn.isUserInteractionEnabled = false
            self.SendCommentBtn.setTitleColor(UIColor.darkGray, for: .normal)
            self.commentContent.text = ""
            
            // Reference for the Anonymous Image
            let anonymousImg = self.anonymousImage.image
            let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.1)
            let anonymousImagePath = "anonymousResponses/\(FIRAuth.auth()!.currentUser!.uid)/anonymousResponserPic.jpg"
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            let anonymousImageRef = self.storageRef2.reference().child(anonymousImagePath)
            anonymousImageRef.put(anonymousImgData!, metadata: metaData, completion: { (metadata, error) in
                if error == nil {
                    // Create the comment whit the user as anonymous
                    let newComment = Comment(questionId: self.selectedQuestion1.questionId, commentText: commentText, commenterImageURL: String(describing: metadata!.downloadURL()!), firstName: self.anonymous, timestamp: NSNumber(value: Date().timeIntervalSince1970))
                    
                    let commentRef = self.databaseRef.child("Questions").child(self.questionKey1!).child("Comments").childByAutoId()
                    
                    commentRef.setValue(newComment.toAnyObject())
                    
                    // Saving the points for the currentUser
                    self.savePoints()
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            // User geat a point
            self.animationPoints()
        }
        
        alertView.showSuccess("✋", subTitle: "Responde como", circleIconImage: alertViewIcon)
        
        // Hide keyboard
        dismissKeyboard()
    }
    
    // Counting and saving the number of points for the currentUser by answering
    func savePoints() {
        let pointsCount: Int?
        if self.currentUser.points == nil {
            pointsCount = 1
        } else {
            pointsCount = self.currentUser.points + 1
        }
        self.databaseRef.child("Users").child(self.currentUser.uid).child("points").setValue(pointsCount)
    }
    
    
    // MARK: - TextView and TextField methods
    
    // TextField delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Limit characters for comments
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // MARK: - Movements for the limit characters
        
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainChar:Int = 300 - newLength
        
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
        
        return (newLength > 300) ? false : true
    }
    
    // Prevent the user from changing the position of the cursor while the placeholder's visible.
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.navigationController!.view.layer.add(transition, forKey: nil)
        self.navigationController!.isNavigationBarHidden = false
        self.navigationController!.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

// MARK: - Table view data source

extension CommentWorldViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return questionArray.count + commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
                        
            let question = self.questionArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! QuestionTableViewCell
            
            cell.configureQuestion(question)
            
            let btn = cell.likesButton!
            cell.tapAction = { (cell) in
                // Counting and saving the number of likes
                if btn.currentImage == UIImage(named: "choclo") {
                    // Updating the value into likes field in Question's Firebase node (+1)
                    self.databaseRef.child("Questions").child(self.questionKey1).child("likes").runTransactionBlock({ (currentData: FIRMutableData!) in
                        var value = currentData.value as? Int
                        
                        //checking for nil data
                        if value == nil {
                            value = 0
                        }
                        
                        // Update value
                        currentData.value = value! + 1
                        
                        return FIRTransactionResult.success(withValue: currentData)
                    })
                    
                    // Saving the question's key in the currentUser's Like subnode as a boolean
                    self.databaseRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).child("Likes").child(self.questionKey1).setValue(true)
                } else {
                    // Updating the value into likes field in Question's Firebase node (-1)
                    self.databaseRef.child("Questions").child(self.questionKey1).child("likes").runTransactionBlock({ (currentData: FIRMutableData!) in
                        var value = currentData.value as? Int
                        
                        //checking for nil data
                        if value == nil {
                            value = 0
                        }
                        
                        // Update value
                        currentData.value = value! - 1
                        
                        return FIRTransactionResult.success(withValue: currentData)
                    })
                    
                    // Removing the boolean value from likes node of currentUser
                    self.databaseRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).child("Likes").child(self.questionKey1).removeValue()
                }
            }
            
            return cell
            
        } else {
            
            var answer: NSDictionary?
            
            answer = self.commentsArray[self.commentsArray.count - indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
            
            cell.configureCell(answer!)
            
            // Adding bottom line to questionCell
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.lightGray.cgColor
            border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  cell.frame.size.width, height: cell.frame.size.height)
            
            border.borderWidth = width
            cell.layer.addSublayer(border)
            cell.layer.masksToBounds = true
            
            return cell
        }
    }
}
