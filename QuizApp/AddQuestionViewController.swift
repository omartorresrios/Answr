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

class AddQuestionViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userImgAnonymous: UIImageView!
    @IBOutlet weak var numberOfComments: UITextField!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var numberOfCharLabel: UILabel!
    @IBOutlet weak var isSwitched: UISwitch!
    @IBOutlet weak var questionImageView: UIImageView! {
        didSet {
            questionImageView.layer.cornerRadius = 5
        }
    }
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
        
        userImgAnonymous.layer.cornerRadius = 5
        
        // Display the user image
        userImgDefault()
        
        // Change size of UISwitch
        isSwitched.transform = CGAffineTransform(scaleX: 0.60, y: 0.60)
        
        questionTextView.becomeFirstResponder()
        
        self.numberOfComments.layer.cornerRadius = 5
        self.numberOfComments.layer.borderWidth = 1

        questionTextView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        let userRef = databaseRef.child("Users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            for userInfo in snapshot.children {
                self.currentUser = User(snapshot: userInfo as! FIRDataSnapshot)
            }
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
    }
    
    // Configure the currentUser image
    func userImgDefault() {
        let userRef = databaseRef.child("Users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            for userInfo in snapshot.children {
                self.currentUser = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            if let user = self.currentUser {
                FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        let alertView = SCLAlertView()
                        alertView.showError("OOPS", subTitle: error.localizedDescription)
                    } else{
                        DispatchQueue.main.async(execute: {
                            if let data = imgData {
                                self.userImgAnonymous.image = UIImage(data: data)
                            }
                        })
                    }
                })
            }
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
    }
    
    // Option (UISwitch) for the user to choose if is anonymous or not
    @IBAction func anonymousUser(_ sender: AnyObject) {
        if isSwitched.isOn {
            userImgAnonymous.image = UIImage(named: "anonymous.jpg")
        } else {
            
            let url = URL(string: currentUser.photoURL)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.userImgAnonymous.image = UIImage(data: data!)
                }
            }
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
        
        if isSwitched.isOn { // Its anonymous
            
            if questionImageView.image!.isEqual(camera) { // Anonymous. Question without image
                
                // Reference for the Anonymous Image
                let anonymousImg = anonymousImage.image
                let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.8)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let anonymousImagePath = "anonymousQuestionsWithoutImage/\(FIRAuth.auth()!.currentUser!.uid)/\(UUID().uuidString)/anonymousQuestionerPic.jpg"
                let anonymousImageRef = storageRef.reference().child(anonymousImagePath)
                anonymousImageRef.put(anonymousImgData!, metadata: metaData, completion: { (metadata, error) in
                    if error == nil {
                        metadata!.downloadURL()
                        
                        // Creating the question
                        let newQuestion = Question(userUid: self.currentUser.uid, questionId: UUID().uuidString, questionText: questionText, questionImageURL: "", questionerImageURL: String(describing: metadata!.downloadURL()!), firstName: self.anonymous, numberOfComments: numberComments, timestamp: NSNumber(value: Date().timeIntervalSince1970), counterComments: self.counter, likes: 0)
                        
                        // Saving the question in Questions node
                        self.saveQuestionInQuestionsNode(question: newQuestion.toAnyObject() as AnyObject)
                        
                        // Saving the question in currentUser feed
                        self.saveMyOwnQuestionInMyFeed(question: newQuestion.questionId as AnyObject, questionId: newQuestion.questionId)
                        
                        // Saving the question in the Feed node of all the followers of the currentUser
                        self.saveQuestionInFeeds(question: newQuestion.questionId as AnyObject, questionId: newQuestion.questionId)
                        
                        // Saving the points for the currentUser
                        self.savePoints()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
            } else {  // Anonymous. Question with image
                
                // Reference for the Question Image
                let imageData = UIImageJPEGRepresentation(questionImageView.image!, 0.8)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let imagePath = "anonymousQuestionsWithImage/\(FIRAuth.auth()!.currentUser!.uid)/\(UUID().uuidString)/questionPic.jpg"
                let imageRef = storageRef.reference().child(imagePath)
                
                // Reference for the Anonymous Image
                let anonymousImg = anonymousImage.image
                let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.8)
                let anonymousImagePath = "anonymousQuestionsWithImage/\(FIRAuth.auth()!.currentUser!.uid)/\(UUID().uuidString)/anonymousQuestionerPic.jpg"
                let anonymousImageRef = storageRef.reference().child(anonymousImagePath)
                anonymousImageRef.put(anonymousImgData!, metadata: metaData, completion: { (metadata, error) in
                    if error == nil {
                        metadata!.downloadURL()
                        
                        imageRef.put(imageData!, metadata: metaData, completion: { (newMetaData, error) in
                            if error == nil {
                                
                                // Creating the question
                                let newQuestion = Question(userUid: self.currentUser.uid, questionId: UUID().uuidString, questionText: questionText, questionImageURL: String(describing: newMetaData!.downloadURL()!), questionerImageURL: String(describing: metadata!.downloadURL()!),firstName: self.anonymous, numberOfComments: numberComments, timestamp: NSNumber(value: Date().timeIntervalSince1970), counterComments: self.counter, likes: 0)
                                
                                // Saving the question in Questions node
                                self.saveQuestionInQuestionsNode(question: newQuestion.toAnyObject() as AnyObject)
                                
                                // Saving the question in currentUser feed
                                self.saveMyOwnQuestionInMyFeed(question: newQuestion.questionId as AnyObject, questionId: newQuestion.questionId)
                                
                                // Saving the question in the Feed node of all the followers of the currentUser
                                self.saveQuestionInFeeds(question: newQuestion.questionId as AnyObject, questionId: newQuestion.questionId)
                                
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
            
        } else { // Its not anonymous
            
            if questionImageView.image!.isEqual(camera) { // Its not anonymous. Question without image
                
                // Creating the question
                let newQuestion = Question(userUid: self.currentUser.uid, questionId: UUID().uuidString, questionText: questionText, questionImageURL: "", questionerImageURL: self.currentUser.photoURL, firstName: self.currentUser.firstName, numberOfComments: numberComments, timestamp: NSNumber(value: Date().timeIntervalSince1970), counterComments: self.counter, likes: 0)
                
                // Saving the question in Questions node
                self.saveQuestionInQuestionsNode(question: newQuestion.toAnyObject() as AnyObject)
                
                // Saving the question in currentUser feed
                self.saveMyOwnQuestionInMyFeed(question: newQuestion.questionId as AnyObject, questionId: newQuestion.questionId)
                
                // Saving the question in the Feed node of all the followers of the currentUser
                self.saveQuestionInFeeds(question: newQuestion.questionId as AnyObject, questionId: newQuestion.questionId)
                
                // Saving the points for the currentUser
                self.savePoints()
                
            } else { // Its not anonymous. Question with image
                
                // Reference for the Question Image
                let imageData = UIImageJPEGRepresentation(questionImageView.image!, 0.8)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let imagePath = "questionsWithImage/\(FIRAuth.auth()!.currentUser!.uid)/\(UUID().uuidString)/questionPic.jpg"
                let imageRef = storageRef.reference().child(imagePath)
                
                imageRef.put(imageData!, metadata: metaData, completion: { (newMetaData, error) in
                    if error == nil {
                        
                        // Creating the question
                        let newQuestion = Question(userUid: self.currentUser.uid, questionId: UUID().uuidString, questionText: questionText, questionImageURL: String(describing: newMetaData!.downloadURL()!), questionerImageURL: self.currentUser.photoURL, firstName: self.currentUser.firstName, numberOfComments: numberComments, timestamp: NSNumber(value: Date().timeIntervalSince1970), counterComments: self.counter, likes: 0)
                        
                        // Saving the question in Questions node
                        self.saveQuestionInQuestionsNode(question: newQuestion.toAnyObject() as AnyObject)
                        
                        // Saving the question in currentUser feed
                        self.saveMyOwnQuestionInMyFeed(question: newQuestion.questionId as AnyObject, questionId: newQuestion.questionId)
                        
                        // Saving the question in the Feed node of all the followers of the currentUser
                        self.saveQuestionInFeeds(question: newQuestion.questionId as AnyObject, questionId: newQuestion.questionId)
                        
                        // Saving the points for the currentUser
                        self.savePoints()

                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
    }
    
    // Function for save the question in Questions node
    func saveQuestionInQuestionsNode(question: AnyObject) {
        let questionRef = self.databaseRef.child("Questions").childByAutoId()
        questionRef.setValue(question, withCompletionBlock: { (error, ref) in
            if error == nil {
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    // Function for save the question in currentUser feed
    func saveMyOwnQuestionInMyFeed(question: AnyObject, questionId: String) {
        let myOwnQuestion = self.databaseRef.child("Users").child(self.currentUser.uid).child("Feed").child(questionId)
        myOwnQuestion.setValue(question, withCompletionBlock: { (error, ref) in
            if error == nil {
                print("My own question added to my Feed!")
            }
        })
    }
    
    // Function for save the question in follower's feeds
    func saveQuestionInFeeds(question: AnyObject, questionId: String) {
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
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        self.questionImageView.image = image
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
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
        self.navigationController?.popToRootViewController(animated: true)
    }
}



