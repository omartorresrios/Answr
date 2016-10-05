//
//  SettingsTableViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 10/4/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordField: UILabel!
    
    var user: User!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        return FIRStorage.storage().reference()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        
        userImageView.layer.cornerRadius = userImageView.layer.frame.height / 2
        
        // Creating Tap Gesture to dismiss Keyboard for the userImageView
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingsTableViewController.choosePictureAction))
        imageTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(imageTapGesture)

        userImageView.userInteractionEnabled = true
        userImageView.addGestureRecognizer(imageTapGesture)
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingsTableViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)

        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(SettingsTableViewController.dismissKeyboard(_:)))
        swipDown.direction = .Down
        view.addGestureRecognizer(swipDown)
    }

    /*override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }*/

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        fetchCurrentUserInfo()
    }
    
    func fetchCurrentUserInfo() {
        let userRef = FIRDatabase.database().reference().child("Users").queryOrderedByChild("uid").queryEqualToValue(FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observeEventType(.Value, withBlock: { (snapshot) in
            for userInfo in snapshot.children {
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            if let user = self.user {
                
                self.nameTextField.text = user.firstName
                self.usernameLabel.text = user.username
                self.emailTextField.text = user.email
                
                FIRStorage.storage().referenceForURL(user.photoURL).dataWithMaxSize(1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        let alertView = SCLAlertView()
                        alertView.showError("OOPS", subTitle: error.localizedDescription)
                        
                    } else{
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            if let data = imgData {
                                self.userImageView.image = UIImage(data: data)
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
    
    @IBAction func updateAction(sender: AnyObject) {
        let name = nameTextField.text!
        let email = emailTextField.text!.lowercaseString
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let userPicture = userImageView.image
        
        let imgData = UIImageJPEGRepresentation(userPicture!, 0.8)!
        
        if name.isEmpty || finalEmail.isEmpty || finalEmail.characters.count < 8 {
            dispatch_async(dispatch_get_main_queue(), {
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: "Hey, it seems like you did not fill correctly the information")
            })
        } else {
            let imagePath = "profileImages/\(self.user.uid)/userPic.jpg"
            
            let imageRef = self.storageRef.child(imagePath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            imageRef.putData(imgData, metadata: metadata) { (metadata, error) in
                if error == nil {
                    
                    FIRAuth.auth()!.currentUser!.updateEmail(finalEmail, completion: { (error) in
                        if error == nil {
                            print("email updated succesfully")
                        } else {
                            let alertView =  SCLAlertView()
                            alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                        }
                    })
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = name
                    
                    if let photoURL = metadata!.downloadURL(){
                        changeRequest.photoURL = photoURL
                    }
                    
                    changeRequest.commitChangesWithCompletion({ (error) in
                        if error == nil {
                            let user = FIRAuth.auth()!.currentUser!
                            let userInfo = ["firstName": name, "email": user.email, "username": self.user.username, "uid": user.uid, "photoURL": String(user.photoURL!)]
                            
                            let userRef = self.databaseRef.child("Users").child(self.user.uid)
                            
                            userRef.setValue(userInfo, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                } else {
                                    let alertView =  SCLAlertView()
                                    alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                                }
                            })
                        }
                        else {
                            let alertView =  SCLAlertView()
                            alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                        }
                    })
                } else {
                    let alertView =  SCLAlertView()
                    alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                }
            }
        }
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        return true
    }
    
    func choosePictureAction() {
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
        self.userImageView.image = image
    }
    
    // Dismissing all editing actions when User Tap or Swipe down on the Main View
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.choosePictureAction()
        }
    }
   
    @IBAction func logoutAction(sender: AnyObject) {
        /*do {
         try FIRAuth.auth()?.signOut()
         if FIRAuth.auth()?.currentUser == nil {
         let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("start") as! StartViewController
         presentViewController(vc, animated: true, completion: nil)
         }
         } catch let error as NSError {
         let alertView = SCLAlertView()
         alertView.showError("OOPS", subTitle: error.localizedDescription)
         }*/

        if FIRAuth.auth()!.currentUser != nil {
            do { // Podríamos obviar esta sentencia do. Averiguar y profundizar bien en esto
                try FIRAuth.auth()?.signOut()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("start") // Podríamos eliminar el StartViewController que se creó
                presentViewController(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                
                let alertView = SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error.localizedDescription)
            }
        }
    }
    
    @IBAction func comeBackAction(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    

}
