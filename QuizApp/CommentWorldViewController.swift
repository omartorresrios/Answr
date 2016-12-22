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

class CommentWorldViewController: UIViewController {

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
        
        initialSetupForCommentContentTextView()
        
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
        
        
        self.hideKeyboardWhenTappedAround1()
        
        //        self.databaseRef.child("Questions").child(self.selectedQuestion.key).child("Comments").observe(.value, with: { (snapshot) in
        //            if !snapshot.exists() {
        //                let indexP = [NSIndexPath.init(row: 1, section: 0)]
        //                tableView.deleteRows(at: indexP as [IndexPath], with: .automatic)
        //                //tableView.reloadData()
        //            }
        //        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchQuestion()
        
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
            numberOfComLabel.text = selectedQuestion1.numberOfComments
            counterCommentsLabel.text = "\(selectedQuestion1.counterComments!)" + "/"
            
            maxNumberComments =  Int(selectedQuestion1.numberOfComments)!
            
            // Check if it shows or hides comment elements
            disabledComments()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchAnswers()
        NotificationCenter.default.addObserver(self, selector: #selector(CommentWorldViewController.showOrHideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentWorldViewController.showOrHideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func initialSetupForCommentContentTextView() {
        commentContent.text = "Responde algo ..."
        commentContent.textColor = UIColor.lightGray
        commentContent.selectedTextRange = commentContent.textRange(from: commentContent.beginningOfDocument, to: commentContent.beginningOfDocument)
    }
    
    // Disabled commentContent and sendButton when comments counter is equal to number of commments
    func disabledComments() {
        if counter == maxNumberComments {
            
            // Remove commentContent, numberOfComLabel and sendButton
            commentStackView.removeFromSuperview()
            
            // Add bottom constraint for tableviewComment to superview
            let tableviewCommentBottom = NSLayoutConstraint (item: tableviewComment, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
            view.addConstraint(tableviewCommentBottom)
            
            // Display UIView from bottom with "No more answers allowed" message
            let y: CGFloat = UIScreen.main.bounds.size.height - view.frame.size.height
            let viewY = view.frame.maxY
            
            let viewWidth = view.bounds.width
            let viewHeight = view.frame.size.height
            
            let noMoreCommentsMsg = UIView(frame: CGRect(x: 0, y: viewY, width: viewWidth, height: 0))
            noMoreCommentsMsg.backgroundColor = UIColor.red
            
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {() -> Void in
                noMoreCommentsMsg.frame = CGRect(x: 0, y: viewHeight - 80, width: viewWidth, height: 30)
                }, completion: {(_ finished: Bool) -> Void in
            })
            self.view.addSubview(noMoreCommentsMsg)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
            selectedQuestion1.ref.child("counterComments").setValue(counter)
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
            let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.1)
            let anonymousImagePath = "anonymousResponses/\(FIRAuth.auth()!.currentUser!.uid)/anonymousResponserPic.jpg"
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            let anonymousImageRef = storageRef2.reference().child(anonymousImagePath)
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
        } else {
            // Create the comment whit the users data
            let newComment = Comment(questionId: self.selectedQuestion1.questionId, commentText: commentText, commenterImageURL: String(describing: FIRAuth.auth()!.currentUser!.photoURL!), firstName: FIRAuth.auth()!.currentUser!.displayName!, timestamp: NSNumber(value: Date().timeIntervalSince1970))
            
            let commentRef = self.databaseRef.child("Questions").child(self.questionKey1!).child("Comments").childByAutoId()
            
            commentRef.setValue(newComment.toAnyObject())
            
            // Saving the points for the currentUser
            self.savePoints()
        }
        
        initialSetupForCommentContentTextView()
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
        
        // MARK: - Movements for the artificial placeholder
        
        // Combine the textView text and the replacement text to create the updated text string
        let currentText: NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        
        // If updated text view will be empty, add the placeholder and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            textView.text = "Responde algo ..."
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            return false
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
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
}

extension UIViewController {
    func hideKeyboardWhenTappedAround1() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard1))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard1() {
        view.endEditing(true)
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
            print("jajajaja: \(self.questionKey1)")
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
            
            //            // Adding bottom line to questionCell
            //            let border = CALayer()
            //            let width = CGFloat(0.5)
            //            border.borderColor = UIColor.lightGray.cgColor
            //            border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  cell.frame.size.width, height: cell.frame.size.height)
            //
            //            border.borderWidth = width
            //            cell.layer.addSublayer(border)
            //            cell.layer.masksToBounds = true
            
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
