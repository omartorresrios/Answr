//
//  LoginViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 9/17/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var authService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
        
        //Setting the delegates for the Textfields
        
        //emailTextField.delegate = self
        passwordTextField.delegate = self
        
        if passwordTextField.text!.isEmpty {
            loginButton.isUserInteractionEnabled = false
        }
    }
    
    override func viewDidLayoutSubviews() {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        navigationController?.isNavigationBarHidden = false
        
        loginButton.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        loginButton.layer.cornerRadius = 15
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText: NSString = textField.text! as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if updatedText.isEmpty {
            loginButton.isUserInteractionEnabled = false
            loginButton.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        } else {
            loginButton.isUserInteractionEnabled = true
            loginButton.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
        }
        return true
    }

    /*
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }*/
    /*
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }*/
    /*
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(textField: UITextField) {
        animateView(true, moveValue: 80)
    }*/
    /*
    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(textField: UITextField) {
        animateView(false, moveValue: 80)
    }*/
    
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(_ up: Bool, moveValue: CGFloat) {
        
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
    
    @IBAction func loginAction(_ sender: AnyObject) {
        self.view.endEditing(true)
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let password = passwordTextField.text!
        
        if finalEmail.isEmpty || password.isEmpty || finalEmail.characters.count < 8 {
            //Present an alertView to your user
            
            DispatchQueue.main.async(execute: {
                let alertView =  SCLAlertView()
                alertView.showError("🙁", subTitle: "Ey, parece que no completaste la información!")
            })
        } else {
            authService.signIn(finalEmail, password: password)
        }
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
