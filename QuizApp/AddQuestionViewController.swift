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
    
    var currentUser: User!
    var counter = 0
    let anonymous: String = "Anonymous" // Anonymous users name
    var anonymousImage: UIImageView! // Anonymous users image
    let camera = UIImage(named: "Camera.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the anonymous image to bgImage
        let image: UIImage = UIImage(named: "anonymous.jpg")!
        anonymousImage = UIImageView(image: image)
        
        self.questionTextView.layer.cornerRadius = 5
        self.questionTextView.layer.borderWidth = 2
        self.questionTextView.layer.borderColor = UIColor(red: 16/255.0, green: 171/255.0, blue: 235/255.0, alpha: 1.0).CGColor
        questionTextView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let userRef = FIRDatabase.database().reference().child("Users").queryOrderedByChild("uid").queryEqualToValue(FIRAuth.auth()!.currentUser!.uid)
        userRef.observeEventType(.Value, withBlock: { (snapshot) in
            for userInfo in snapshot.children {
                self.currentUser = User(snapshot: userInfo as! FIRDataSnapshot)
            }
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
    }
    
    @IBAction func showPictureAction(sender: AnyObject) {
        if isSwitched.on {
            questionImageView.alpha = 1.0
        } else {
            questionImageView.alpha = 0.0
        }
    }

    @IBAction func saveQuestionAction(sender: AnyObject) {
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
        
        if isSwitched.on { // Its anonymous
            
            if questionImageView.image!.isEqual(camera) { // Anonymous. Question without image
                
                // Reference for the Anonymous Image
                let anonymousImg = anonymousImage.image
                let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.8)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let anonymousImagePath = "anonymousQuestionsWithoutImage/\(FIRAuth.auth()!.currentUser!.uid)/anonymousQuestionerPic.jpg"
                let anonymousImageRef = storageRef.reference().child(anonymousImagePath)
                anonymousImageRef.putData(anonymousImgData!, metadata: metaData, completion: { (metadata, error) in
                    if error == nil {
                        metadata!.downloadURL()
                        
                        let newQuestion = Question(username: self.currentUser.username, questionId: NSUUID().UUIDString, questionText: questionText, questionImageURL: "", questionerImageURL: String(metadata!.downloadURL()!),firstName: self.anonymous, numberOfComments: numberComments, counterComments: self.counter)
                                
                        let questionRef = self.databaseRef.child("Questions").childByAutoId()
                        questionRef.setValue(newQuestion.toAnyObject(), withCompletionBlock: { (error, ref) in
                            if error == nil {
                                self.navigationController?.popToRootViewControllerAnimated(true)
                            }
                        })
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
            } else {  // Anonymous. Question with image
                
                // Reference for the Question Image
                let imageData = UIImageJPEGRepresentation(questionImageView.image!, 0.8)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let imagePath = "anonymousQuestionsWithImage/\(FIRAuth.auth()!.currentUser!.uid)/questionPic.jpg"
                let imageRef = storageRef.reference().child(imagePath)
                
                // Reference for the Anonymous Image
                let anonymousImg = anonymousImage.image
                let anonymousImgData = UIImageJPEGRepresentation(anonymousImg!, 0.8)
                let anonymousImagePath = "anonymousQuestionsWithImage/\(FIRAuth.auth()!.currentUser!.uid)/anonymousQuestionerPic.jpg"
                let anonymousImageRef = storageRef.reference().child(anonymousImagePath)
                anonymousImageRef.putData(anonymousImgData!, metadata: metaData, completion: { (metadata, error) in
                    if error == nil {
                        metadata!.downloadURL()
                        
                        imageRef.putData(imageData!, metadata: metaData, completion: { (newMetaData, error) in
                            if error == nil {
                                
                                let newQuestion = Question(username: self.currentUser.username, questionId: NSUUID().UUIDString, questionText: questionText, questionImageURL: String(newMetaData!.downloadURL()!), questionerImageURL: String(metadata!.downloadURL()!),firstName: self.anonymous, numberOfComments: numberComments, counterComments: self.counter)
                                
                                let questionRef = self.databaseRef.child("Questions").childByAutoId()
                                questionRef.setValue(newQuestion.toAnyObject(), withCompletionBlock: { (error, ref) in
                                    if error == nil {
                                        self.navigationController?.popToRootViewControllerAnimated(true)
                                    }
                                })
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
                
                let newQuestion = Question(username: self.currentUser.username, questionId: NSUUID().UUIDString, questionText: questionText, questionImageURL: "", questionerImageURL: self.currentUser.photoURL, firstName: self.currentUser.firstName, numberOfComments: numberComments, counterComments: self.counter)
                
                let questionRef = self.databaseRef.child("Questions").childByAutoId()
                questionRef.setValue(newQuestion.toAnyObject(), withCompletionBlock: { (error, ref) in
                    if error == nil {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                })
                
            } else { // Its not anonymous. Question with image
                
                // Reference for the Question Image
                let imageData = UIImageJPEGRepresentation(questionImageView.image!, 0.8)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let imagePath = "questionsWithImage/\(FIRAuth.auth()!.currentUser!.uid)/questionPic.jpg"
                let imageRef = storageRef.reference().child(imagePath)
                
                imageRef.putData(imageData!, metadata: metaData, completion: { (newMetaData, error) in
                    if error == nil {
                        
                        let newQuestion = Question(username: self.currentUser.username, questionId: NSUUID().UUIDString, questionText: questionText, questionImageURL: String(newMetaData!.downloadURL()!), questionerImageURL: self.currentUser.photoURL, firstName: self.currentUser.firstName, numberOfComments: numberComments, counterComments: self.counter)
                        
                        let questionRef = self.databaseRef.child("Questions").childByAutoId()
                        questionRef.setValue(newQuestion.toAnyObject(), withCompletionBlock: { (error, ref) in
                            if error == nil {
                                self.navigationController?.popToRootViewControllerAnimated(true)
                            }
                        })
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
    }
    
    @IBAction func choosePictureAction(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From", preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (action) in
            pickerController.sourceType = .Camera
            self.presentViewController(pickerController, animated: true, completion: nil)
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .Default) { (action) in
            pickerController.sourceType = .PhotoLibrary
            self.presentViewController(pickerController, animated: true, completion: nil)
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .Default) { (action) in
            pickerController.sourceType = .SavedPhotosAlbum
            self.presentViewController(pickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.questionImageView.image = image
    }

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainChar:Int = 200 - newLength
        
        numberOfCharLabel.text = "\(remainChar)"
        if remainChar == -1 {
            numberOfCharLabel.text = "0"
            numberOfCharLabel.textColor = UIColor.redColor()
        } else {
            numberOfCharLabel.textColor = UIColor.blackColor()
            numberOfCharLabel.text = "\(remainChar)"
        }
        return (newLength > 200) ? false : true
    }
    
}
