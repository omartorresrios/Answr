//
//  SettingsViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 6/01/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import XLActionController
import JDStatusBarNotification

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var password: UILabel!    
    @IBOutlet weak var logoutButton: UIButton!
    
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
        
        UIApplication.shared.isStatusBarHidden = false
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 18/255.0, green: 165/255.0, blue: 244/255.0, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]

        
        // Top line to some views
        topBorder(uiView: emailView)
        topBorder(uiView: usernameView)
        topBorder(uiView: passwordView)
        
        // Intitial UI for some elements
        self.checkmark.alpha = 0
        self.loader.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        logoutButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
        
        
        // Create tap gesture to tap name, email and password views for go to respective edit views
        let nameTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.nameTap(gesture:)))
        nameTapGestureRecognizer.numberOfTapsRequired = 1
        name.addGestureRecognizer(nameTapGestureRecognizer)
        name.isUserInteractionEnabled = true
        
        let emailTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.emailTap(gesture:)))
        emailTapGestureRecognizer.numberOfTapsRequired = 1
        email.addGestureRecognizer(emailTapGestureRecognizer)
        email.isUserInteractionEnabled = true
        
        let passwordTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.passwordTap(gesture:)))
        passwordTapGestureRecognizer.numberOfTapsRequired = 1
        password.addGestureRecognizer(passwordTapGestureRecognizer)
        password.isUserInteractionEnabled = true
        
        // Create tap gesture to username view and display message at the top of view
        let usernameTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.usernameTap(gesture:)))
        usernameTapGestureRecognizer.numberOfTapsRequired = 1
        username.addGestureRecognizer(usernameTapGestureRecognizer)
        username.isUserInteractionEnabled = true


        // Creating Tap Gesture to dismiss Keyboard for the userImageView
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.choosePictureAction))
        imageTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(imageTapGesture)
        
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(imageTapGesture)
        
        fetchCurrentUserInfo()
        
        // Reachability for checking internet connection
        NotificationCenter.default.addObserver(self, selector: #selector(AddQuestionViewController.reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
    }
    
    func reachabilityStatusChanged() {
        if reachability?.isReachable == false {
            print("JAJAJ")//saveButton.isUserInteractionEnabled = false
        }
    }
    
    func topBorder(uiView: UIView) {
        let emailTopBorder = CALayer()
        emailTopBorder.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(uiView.frame.size.width), height: CGFloat(1.0))
        emailTopBorder.backgroundColor = UIColor(colorLiteralRed: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1).cgColor
        uiView.layer.addSublayer(emailTopBorder)
    }
    
    func nameTap(gesture: UIGestureRecognizer){
        performSegue(withIdentifier: "showName", sender: self)
    }
    
    func emailTap(gesture: UIGestureRecognizer){
        performSegue(withIdentifier: "showEmail", sender: self)
    }
    
    func usernameTap(gesture: UIGestureRecognizer){
        JDStatusBarNotification.show(withStatus: "No puedes editar tu nombre de usuario", dismissAfter: 2.0, styleName: JDStatusBarStyleDark)
    }
    
    func passwordTap(gesture: UIGestureRecognizer){
        performSegue(withIdentifier: "showPassword", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchCurrentUserInfo() {
        let userRef = FIRDatabase.database().reference().child("Users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observe(.value, with: { (snapshot) in
            for userInfo in snapshot.children {
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            if let user = self.user {
                
                self.name.text! = user.firstName
                self.username.text! = user.username
                self.email.text! = user.email!
                
                FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showName" {
            let showNameVC = segue.destination as! UpdateNameViewController
            
            showNameVC.user = self.user
            showNameVC.oldName = self.name.text!
        }
        
        if segue.identifier == "showEmail" {
            let showEmailVC = segue.destination as! UpdateEmailViewController
            
            showEmailVC.user = self.user
            showEmailVC.oldEmail = self.email.text!
            showEmailVC.name = self.name.text!
        }
        
        if segue.identifier == "showPassword" {
            let showPasswordVC = segue.destination as! UpdatePasswordViewController
            
            showPasswordVC.user = self.user
            
        }
        
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
        
        
        self.loader.startAnimating()
        
        self.userImageView.image = image
        self.userImageView.alpha = 0.2
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            //self.userImageView.image = image
            
            let name = self.name.text!
            
            let imgData = UIImageJPEGRepresentation(image, 0.1)!
            
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
                            
                            
                            userRef.child("photoURL").setValue(String(describing: self.currentUser.photoURL!), withCompletionBlock: { (error, ref) in
                                
                                if error == nil {
                                    print("currentUser photoURL updated")
                                    
                                    self.loader.stopAnimating()
                                    
                                    UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [.curveEaseIn], animations: {
                                        self.checkmark.alpha = 1
                                        }, completion: {(_ finished: Bool) -> Void in
                                            self.checkmark.alpha = 0
                                            self.userImageView.alpha = 1
                                    })
                                    
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("🙁", subTitle: "Hubo un problema, no se pudo actualizar. Intenta de nuevo!")
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
    
    @IBAction func logoutAction(_ sender: AnyObject) {
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "logo")
        
        alertView.addButton("Sí") {
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
        alertView.showInfo("✋", subTitle: "¿Quieres salir?", circleIconImage: alertViewIcon)
        //alertView.showError("Salir", subTitle: "¿Seguro que quieres salir?", circleIconImage: alertViewIcon)
        //alertView.showWarning("Salir", subTitle: "¿Seguro que quieres salir?", circleIconImage: alertViewIcon)
        //alertView.showNotice("Salir", subTitle: "¿Seguro que quieres salir?", circleIconImage: alertViewIcon)
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller is MyProfileViewController {
                self.navigationController!.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
        
    }

}
