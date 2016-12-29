//
//  SignUpViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 9/17/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import XLActionController

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var firstNameV5: UITextField!
    var usernameV5: UITextField!
    var passwordV5: UITextField!
    var emailV5: UITextField!
    let userImgDefault = UIImage(named: "User")
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var authService = AuthenticationService()
    
    override func viewDidLayoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
        
        if userImageView.image!.isEqual(userImgDefault) {
            signupButton.isUserInteractionEnabled = false
            signupButton.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        } else {
            signupButton.isUserInteractionEnabled = true
            signupButton.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loader.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        
        //signupButton.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        signupButton.layer.cornerRadius = 15
    }
    
    //Signin Up the user
    @IBAction func signUpAction(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.loader.startAnimating()
        
        let email = emailV5.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let firstName = firstNameV5.text!
        let password = passwordV5.text!
        let username = usernameV5.text!
        let userPicture = userImageView.image
        
        let imgData = UIImageJPEGRepresentation(userPicture!, 0.1)
        
        authService.signUp(finalEmail, firstName: firstName, username: username, password: password, data: imgData!)
        
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
        self.userImageView.image = image
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
