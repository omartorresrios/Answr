//
//  AddQuestionViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 9/18/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import XLActionController

class AddQuestionViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var numberOfComments: UITextField!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var numberOfCharLabel: UILabel!
    @IBOutlet weak var questionImageView: UIImageView! {
        didSet {
            questionImageView.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet var testView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    var questionsArray = [NSDictionary?]()
    var currentUser: User!
    var otherUser: NSDictionary?
    var counter = 0
    let anonymous: String = "Anonymous" // Anonymous users name
    var anonymousImage: UIImageView! // Anonymous users image
    let camera = UIImage(named: "Camera.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isStatusBarHidden = false
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        
        questionTextView.becomeFirstResponder()
        
        self.loader.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        // Set the anonymous image to bgImage
        let image: UIImage = UIImage(named: "anonymous.jpg")!
        anonymousImage = UIImageView(image: image)
        
        self.numberOfComments.layer.cornerRadius = 5
        self.numberOfComments.layer.borderWidth = 1

        questionTextView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = true
        
        // Adding targets to sendButton if its enable
        if sendButton.isUserInteractionEnabled == true {
            sendButton.addTarget(self, action: #selector(AddQuestionViewController.buttonPress(_:)), for: .touchDown)
            sendButton.addTarget(self, action: #selector(AddQuestionViewController.buttonRelease(_:)), for: .touchUpInside)
            sendButton.addTarget(self, action: #selector(AddQuestionViewController.buttonRelease(_:)), for: .touchUpOutside)
            
            let sendBtnLongPress = UILongPressGestureRecognizer(target: self, action: #selector(AddQuestionViewController.lonPress(_:)))
            sendButton.addGestureRecognizer(sendBtnLongPress)
            
            NotificationCenter.default.addObserver(self, selector: #selector(AddQuestionViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        let viewWidth = view.bounds.width
        let viewHeight = view.frame.size.height
        
        testView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight - keyboardHeight)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        let userRef = databaseRef.child("Users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            for userInfo in snapshot.children {
                self.currentUser = User(snapshot: userInfo as! FIRDataSnapshot)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // Scale up on sendButton press
    func buttonPress(_ button: UIButton) {
        sendButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 4.0,
                       options: .allowUserInteraction, animations: { [weak self] in
                        self?.sendButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: nil)
    }
    
    // Scale down sendbutton release
    func buttonRelease(_ button: UIButton) {
        sendButton.transform = .identity
    }
    
    // Scale down sendbutton release when tapped long time
    func lonPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 4.0,
                           options: .allowUserInteraction, animations: { [weak self] in
                            self?.sendButton.transform = .identity
                }, completion: nil)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        // Enabled/disabled senButton
        if !textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            sendButton.isUserInteractionEnabled = true
            sendButton.setImage(UIImage(named: "SentEna"), for: .normal)
        } else {
            sendButton.isUserInteractionEnabled = false
            sendButton.setImage(UIImage(named: "SentDis"), for: .normal)
        }
        
    }
    
    @IBAction func saveQuestionAction(_ sender: AnyObject) {
        
        var questionText: String!
        if let text: String = questionTextView.text {
            questionText = text
        } else {
            questionText = ""
        }
        
        var numberComments: String!
        if let number: String = numberOfComments.text {
            numberComments = number
        } else {
            numberComments = ""
        }
        
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "logo")
        
        
        
        
        alertView.addButton("Pregunta como \(FIRAuth.auth()!.currentUser!.displayName!)") {
            
            self.loader.startAnimating()
            
            if self.questionImageView.image!.isEqual(self.camera) { // Its not anonymous. Question without image
                
                // Creating the question
                let newQuestion = Question(userUid: self.currentUser.uid, questionId: UUID().uuidString, questionText: questionText, questionImageURL: "", questionerImageURL: self.currentUser.photoURL, firstName: self.currentUser.firstName, numberOfComments: numberComments, timestamp: NSNumber(value: Date().timeIntervalSince1970), counterComments: self.counter, likes: 0)
                
                // Saving the question in Questions node
                self.saveQuestionInQuestionsNode(newQuestion.toAnyObject() as AnyObject)
                
                // Saving the question in currentUser feed
                self.saveMyOwnQuestionInMyFeed(newQuestion.toAnyObject() as AnyObject, questionId: newQuestion.questionId)
                
                // Saving the question in the Feed node of all the followers of the currentUser
                self.saveQuestionInFeeds(newQuestion.toAnyObject() as AnyObject, questionId: newQuestion.questionId)
                
                // Saving the points for the currentUser
                self.savePoints()
                
            } else { // Its not anonymous. Question with image
                
                // Reference for the Question Image
                let imageData = UIImageJPEGRepresentation(self.questionImageView.image!, 0.8)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let imagePath = "questionsWithImage/\(FIRAuth.auth()!.currentUser!.uid)/\(UUID().uuidString)/questionPic.jpg"
                let imageRef = self.storageRef.reference().child(imagePath)
                
                imageRef.put(imageData!, metadata: metaData, completion: { (newMetaData, error) in
                    if error == nil {
                        
                        // Creating the question
                        let newQuestion = Question(userUid: self.currentUser.uid, questionId: UUID().uuidString, questionText: questionText, questionImageURL: String(describing: newMetaData!.downloadURL()!), questionerImageURL: self.currentUser.photoURL, firstName: self.currentUser.firstName, numberOfComments: numberComments, timestamp: NSNumber(value: Date().timeIntervalSince1970), counterComments: self.counter, likes: 0)
                        
                        // Saving the question in Questions node
                        self.saveQuestionInQuestionsNode(newQuestion.toAnyObject() as AnyObject)
                        
                        // Saving the question in currentUser feed
                        self.saveMyOwnQuestionInMyFeed(newQuestion.toAnyObject() as AnyObject, questionId: newQuestion.questionId)
                        
                        // Saving the question in the Feed node of all the followers of the currentUser
                        self.saveQuestionInFeeds(newQuestion.toAnyObject() as AnyObject, questionId: newQuestion.questionId)
                        
                        // Saving the points for the currentUser
                        self.savePoints()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        alertView.addButton("Pregunta como anónimo") {
            
            self.loader.startAnimating()
            
            if self.questionImageView.image!.isEqual(self.camera) { // Anonymous. Question without image
                
                // Reference for the Anonymous Image
                let anonymousImg = self.anonymousImage.image
                let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.1)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let anonymousImagePath = "anonymousQuestionsWithoutImage/\(FIRAuth.auth()!.currentUser!.uid)/\(UUID().uuidString)/anonymousQuestionerPic.jpg"
                let anonymousImageRef = self.storageRef.reference().child(anonymousImagePath)
                anonymousImageRef.put(anonymousImgData!, metadata: metaData, completion: { (metadata, error) in
                    if error == nil {
                        metadata!.downloadURL()
                        
                        // Creating the question
                        let newQuestion = Question(userUid: self.currentUser.uid, questionId: UUID().uuidString, questionText: questionText, questionImageURL: "", questionerImageURL: String(describing: metadata!.downloadURL()!), firstName: self.anonymous, numberOfComments: numberComments, timestamp: NSNumber(value: Date().timeIntervalSince1970), counterComments: self.counter, likes: 0)
                        
                        // Saving the question in Questions node
                        self.saveQuestionInQuestionsNode(newQuestion.toAnyObject() as AnyObject)
                        
                        // Saving the question in currentUser feed
                        self.saveMyOwnQuestionInMyFeed(newQuestion.toAnyObject() as AnyObject, questionId: newQuestion.questionId)
                        
                        // Saving the question in the Feed node of all the followers of the currentUser
                        self.saveQuestionInFeeds(newQuestion.toAnyObject() as AnyObject, questionId: newQuestion.questionId)
                        
                        // Saving the points for the currentUser
                        self.savePoints()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
            } else {  // Anonymous. Question with image
                
                // Reference for the Question Image
                let imageData = UIImageJPEGRepresentation(self.questionImageView.image!, 0.8)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let imagePath = "anonymousQuestionsWithImage/\(FIRAuth.auth()!.currentUser!.uid)/\(UUID().uuidString)/questionPic.jpg"
                let imageRef = self.storageRef.reference().child(imagePath)
                
                // Reference for the Anonymous Image
                let anonymousImg = self.anonymousImage.image
                let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.1)
                let anonymousImagePath = "anonymousQuestionsWithImage/\(FIRAuth.auth()!.currentUser!.uid)/\(UUID().uuidString)/anonymousQuestionerPic.jpg"
                let anonymousImageRef = self.storageRef.reference().child(anonymousImagePath)
                anonymousImageRef.put(anonymousImgData!, metadata: metaData, completion: { (metadata, error) in
                    if error == nil {
                        metadata!.downloadURL()
                        
                        imageRef.put(imageData!, metadata: metaData, completion: { (newMetaData, error) in
                            if error == nil {
                                
                                // Creating the question
                                let newQuestion = Question(userUid: self.currentUser.uid, questionId: UUID().uuidString, questionText: questionText, questionImageURL: String(describing: newMetaData!.downloadURL()!), questionerImageURL: String(describing: metadata!.downloadURL()!),firstName: self.anonymous, numberOfComments: numberComments, timestamp: NSNumber(value: Date().timeIntervalSince1970), counterComments: self.counter, likes: 0)
                                
                                // Saving the question in Questions node
                                self.saveQuestionInQuestionsNode(newQuestion.toAnyObject() as AnyObject)
                                
                                // Saving the question in currentUser feed
                                self.saveMyOwnQuestionInMyFeed(newQuestion.toAnyObject() as AnyObject, questionId: newQuestion.questionId)
                                
                                // Saving the question in the Feed node of all the followers of the currentUser
                                self.saveQuestionInFeeds(newQuestion.toAnyObject() as AnyObject, questionId: newQuestion.questionId)
                                
                                // Saving the points for the currentUser
                                self.savePoints()
                                
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
            
        }
        
        alertView.showSuccess("Custom icon", subTitle: "This is a nice alert with a custom icon you choose", circleIconImage: alertViewIcon)
        
        dismissKeyboard()
    }
    
    // Function for save the question in Questions node
    func saveQuestionInQuestionsNode(_ question: AnyObject) {
        let questionRef = self.databaseRef.child("Questions").childByAutoId()
        questionRef.setValue(question, withCompletionBlock: { (error, ref) in
            if error == nil {
                self.loader.stopAnimating()
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.tabBarController?.tabBar.isHidden = false
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    // Function for save the question in currentUser feed
    func saveMyOwnQuestionInMyFeed(_ question: AnyObject, questionId: String) {
        let myOwnQuestion = self.databaseRef.child("Users").child(self.currentUser.uid).child("Feed").child(questionId)
        myOwnQuestion.setValue(question, withCompletionBlock: { (error, ref) in
            if error == nil {
                print("My own question added to my Feed!")
            }
        })
    }
    
    // Function for save the question in follower's feeds
    func saveQuestionInFeeds(_ question: AnyObject, questionId: String) {
        self.databaseRef.child("followers").child(self.currentUser.uid).observe(.value, with: { (snapshot) in
            for follower in snapshot.children {
                let followerSnapshot = User(snapshot: follower as! FIRDataSnapshot)
                
                let followerRef = self.databaseRef.child("Users").child(followerSnapshot.uid).child("Feed").child(questionId)
                followerRef.setValue(question, withCompletionBlock: { (error, ref) in
                    if error == nil {
                        print("Question added to follower's feed")
                    }
                })
            }
        })
    }
    
    // Counting and saving the number of points for the currentUser by asking
    func savePoints() {
        let pointsCount: Int?
        if self.currentUser.points == nil {
            pointsCount = 1
        } else {
            pointsCount = self.currentUser.points + 1
        }
        self.databaseRef.child("Users").child(self.currentUser.uid).child("points").setValue(pointsCount)
    }
    
    @IBAction func choosePictureAction(_ sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let actionController = SkypeActionController()
        
        actionController.addAction(Action("Cámara", style: .default, handler: { action in
        }))
        actionController.addAction(Action("Librería", style: .default, handler: { action in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }))
        actionController.addAction(Action("Álbum de fotos guardadas", style: .default, handler: { action in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
        }))
        actionController.addAction(Action("Cancelar", style: .cancel, handler: nil))
        
        present(actionController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        self.questionImageView.image = image
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
                
        // Movements to limit characters
        let remainChar:Int = 300 - newLength
        
        numberOfCharLabel.text = "\(remainChar)"
        if remainChar == -1 {
            numberOfCharLabel.text = "0"
            numberOfCharLabel.textColor = UIColor.red
        } else {
            numberOfCharLabel.textColor = UIColor.black
            numberOfCharLabel.text = "\(remainChar)"
        }
        return (newLength > 300) ? false : true
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



