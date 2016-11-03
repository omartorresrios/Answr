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
    let currentUser = FIRAuth.auth()!.currentUser!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorageReference! {
        return FIRStorage.storage().reference()
    }
    override func viewDidLayoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        
        // Creating Tap Gesture to dismiss Keyboard for the userImageView
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingsTableViewController.choosePictureAction))
        imageTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(imageTapGesture)

        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(imageTapGesture)
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingsTableViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)

        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(SettingsTableViewController.dismissKeyboard(_:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
        
        fetchCurrentUserInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func fetchCurrentUserInfo() {
        let userRef = FIRDatabase.database().reference().child("Users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observe(.value, with: { (snapshot) in
            for userInfo in snapshot.children {
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            if let user = self.user {
                
                self.nameTextField.text = user.firstName
                self.usernameLabel.text = user.username
                self.emailTextField.text = user.email
                
                FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        let alertView = SCLAlertView()
                        alertView.showError("OOPS", subTitle: error.localizedDescription)
                        
                    } else{
                        
                        DispatchQueue.main.async(execute: {
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
    
    @IBAction func updateAction(_ sender: AnyObject) {
        
        let name = nameTextField.text!
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let userPicture = userImageView.image
        
        let imgData = UIImageJPEGRepresentation(userPicture!, 0.8)!
        
        if name.isEmpty || finalEmail.isEmpty || finalEmail.characters.count < 8 {
            DispatchQueue.main.async(execute: {
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: "Hey, it seems like you did not fill correctly the information")
            })
        } else {
            let imagePath = "profileImages/\(self.user.uid)/userPic.jpg"
            
            let imageRef = self.storageRef.child(imagePath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            imageRef.put(imgData, metadata: metadata) { (metadata, error) in
                if error == nil {
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = name
                    
                    if let photoURL = metadata!.downloadURL(){
                        changeRequest.photoURL = photoURL
                    }
                    
                    changeRequest.commitChanges(completion: { (error) in
                        if error == nil {
                            let userRef = self.databaseRef.child("Users").child(self.user.uid)
                            userRef.child("firstName").setValue(name, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    print("currentUser firstName updated")
                                    // Once updated, return to MyProfileViewController
                                    for controller in self.navigationController!.viewControllers as Array {
                                        if controller is MyProfileViewController {
                                            self.navigationController!.popToViewController(controller as UIViewController, animated: true)
                                            break
                                        }
                                    }
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("OOPS", subTitle: error!.localizedDescription)
                                }
                            })
                            
                            userRef.child("photoURL").setValue(String(describing: self.currentUser.photoURL!), withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    print("currentUser photoURL updated")
                                }
                            })
                            
                            userRef.child("email").setValue(email, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    print("currentUser email updated")
                                }
                            })
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            }
        }
        
        
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        return true
    }
    
    func choosePictureAction() {
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
        self.userImageView.image = image
    }
    
    // Dismissing all editing actions when User Tap or Swipe down on the Main View
    func dismissKeyboard(_ gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            self.choosePictureAction()
        }
    }
   
    @IBAction func logoutAction(_ sender: AnyObject) {
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
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "start") // Podríamos eliminar el StartViewController que se creó
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                
                let alertView = SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error.localizedDescription)
            }
        }
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        
        //let viewControllers: UIViewController = self.navigationController!.viewControllers as! UIViewController

        
        for controller in self.navigationController!.viewControllers as Array {
            if controller is MyProfileViewController {
                self.navigationController!.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
        
        
        //navigationController!.popViewController(animated: true)
        //navigationController!.popToViewController(navigationController!.viewControllers[1], animated: true)
        
    }
    

}
