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
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    var authService = AuthenticationService()
    
    override func viewDidLayoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
        
        // Bottom line to firstNameTextField
        let borderBottomName = CALayer()
        let borderWidthName = CGFloat(2.0)
        borderBottomName.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomName.frame = CGRect(x: 0, y: firstNameTextField.frame.height - 1.0, width: firstNameTextField.frame.width , height: firstNameTextField.frame.height - 1.0)
        borderBottomName.borderWidth = borderWidthName
        firstNameTextField.layer.addSublayer(borderBottomName)
        firstNameTextField.layer.masksToBounds = true
        
        // Bottom line to usernameTextField
        let borderBottomAlias = CALayer()
        let borderWidthAlias = CGFloat(2.0)
        borderBottomAlias.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomAlias.frame = CGRect(x: 0, y: usernameTextField.frame.height - 1.0, width: usernameTextField.frame.width , height: usernameTextField.frame.height - 1.0)
        borderBottomAlias.borderWidth = borderWidthAlias
        usernameTextField.layer.addSublayer(borderBottomAlias)
        usernameTextField.layer.masksToBounds = true
        
        // Bottom line to emailTextField
        let borderBottomEmail = CALayer()
        let borderWidthEmail = CGFloat(2.0)
        borderBottomEmail.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomEmail.frame = CGRect(x: 0, y: emailTextField.frame.height - 1.0, width: emailTextField.frame.width , height: emailTextField.frame.height - 1.0)
        borderBottomEmail.borderWidth = borderWidthEmail
        emailTextField.layer.addSublayer(borderBottomEmail)
        emailTextField.layer.masksToBounds = true
        
        // Bottom line to passwordTextField
        let borderBottomPass = CALayer()
        let borderWidthPass = CGFloat(2.0)
        borderBottomPass.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomPass.frame = CGRect(x: 0, y: passwordTextField.frame.height - 1.0, width: passwordTextField.frame.width , height: passwordTextField.frame.height - 1.0)
        borderBottomPass.borderWidth = borderWidthPass
        passwordTextField.layer.addSublayer(borderBottomPass)
        passwordTextField.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.becomeFirstResponder()
        
        userImageView.layer.cornerRadius = userImageView.layer.frame.height / 2
        
        //usernameTextField.delegate = self
        passwordTextField.delegate = self
        //emailTextField.delegate = self
        //firstNameTextField.delegate = self
        
        navigationController?.isNavigationBarHidden = false
        
        if firstNameTextField.text!.isEmpty || usernameTextField.text!.isEmpty || emailTextField.text!.isEmpty || emailTextField.text!.characters.count < 8 || passwordTextField.text!.isEmpty {
            signupButton.isUserInteractionEnabled = false
        }
        
        /*
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard(_:)))
        swipDown.direction = .Down
        view.addGestureRecognizer(swipDown)*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        
        signupButton.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        signupButton.layer.cornerRadius = 15
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText: NSString = textField.text! as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if updatedText.isEmpty {
            signupButton.isUserInteractionEnabled = false
            signupButton.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        } else {
            signupButton.isUserInteractionEnabled = true
            signupButton.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
        }
        return true
    }

    //Signin Up the user
    @IBAction func signUpAction(_ sender: AnyObject) {
        self.view.endEditing(true)
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let firstName = firstNameTextField.text!
        let password = passwordTextField.text!
        let username = usernameTextField.text!
        let userPicture = userImageView.image
        
        let imgData = UIImageJPEGRepresentation(userPicture!, 0.8)
        
        if firstName.isEmpty || username.isEmpty || finalEmail.isEmpty || finalEmail.characters.count < 8 || password.isEmpty {
            DispatchQueue.main.async(execute: {
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: "Hey, it seems like you did not fill correctly the information")
            })
        } else {
            authService.signUp(finalEmail, firstName: firstName, username: username, password: password, data: imgData!)
        }
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
    /*
    // Dismissing all editing actions when User Tap or Swipe down on the Main View
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }*/
    /*
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        return true
    }*/
    /*
    // Moving the View up after the Keyboard appears
    func textFieldDidBeginEditing(textField: UITextField) {
        animateView(true, moveValue: 80)
    }*/
    /*
    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(textField: UITextField) {
        animateView(false, moveValue: 80)
    }*/
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(_ up: Bool, moveValue: CGFloat){
        
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
