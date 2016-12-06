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
import XLActionController
import SVProgressHUD

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
    var progress: Float = 0.0
    
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
        })
    }
    
    func increaseProgress() {
        progress += 0.05
        SVProgressHUD.showProgress(progress, status: "Actualizando ...")
        if progress < 1.0 {
            self.perform(#selector(self.increaseProgress), with: nil, afterDelay: 0.1)
        }
        else {
            self.perform(#selector(self.dismiss), with: nil, afterDelay: 0.4)
        }
    }
    
    @IBAction func updateAction(_ sender: AnyObject) {
        progress = 0.0
        SVProgressHUD.showProgress(0, status: "Actualizando ...")
        self.perform(#selector(self.increaseProgress), with: nil, afterDelay: 0.1)

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
                                    SVProgressHUD.showSuccess(withStatus: "Actualizado!")
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
        
        if FIRAuth.auth()!.currentUser != nil {
            do {
                try? FIRAuth.auth()!.signOut()
                
                if FIRAuth.auth()?.currentUser == nil {
                    let startViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "start")
                    
                    self.present(startViewController, animated: true, completion: nil)
                }
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
